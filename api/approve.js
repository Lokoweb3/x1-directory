// api/approve.js
// Handles admin approve and reject actions.
// Requires a valid Supabase session token - never trust the client.

const { createClient } = require('@supabase/supabase-js');

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Extract session token from Authorization header
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) {
    return res.status(401).json({ error: 'Unauthorised' });
  }

  // Create a client scoped to this user's session
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY,
    { global: { headers: { Authorization: `Bearer ${token}` } } }
  );

  // Verify the session is valid and the user is authenticated
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) {
    return res.status(401).json({ error: 'Invalid session' });
  }

  const { submissionId, action, adminNote } = req.body;

  if (!submissionId || !['approved', 'rejected'].includes(action)) {
    return res.status(400).json({ error: 'Invalid request' });
  }

  // Use service key for the actual data operation
  const adminClient = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

  // Fetch the submission
  const { data: submission, error: fetchError } = await adminClient
    .from('submissions')
    .select('*')
    .eq('id', submissionId)
    .single();

  if (fetchError || !submission) {
    return res.status(404).json({ error: 'Submission not found' });
  }

  // Update submission status
  const { error: updateError } = await adminClient
    .from('submissions')
    .update({
      status: action,
      admin_note: adminNote || null,
      reviewed_at: new Date().toISOString(),
    })
    .eq('id', submissionId);

  if (updateError) {
    return res.status(500).json({ error: 'Failed to update submission' });
  }

  // If approved, add to the public projects table
  if (action === 'approved') {
    const iconMap = {
      DeFi:   '\u21C4',
      NFT:    '\u25A6',
      Bridge: '\u27F7',
      Tool:   '\u25C9',
      DAO:    '\u2B21',
      Social: '\u25CE',
      Infra:  '\u229C',
    };
    const { error: insertError } = await adminClient
      .from('projects')
      .insert({
        name: submission.name,
        description: submission.description,
        category: submission.category,
        url: submission.url,
        tags: submission.tags,
        twitter: submission.twitter,
        contract: submission.contract,
        icon: iconMap[submission.category] || '\u25C8',
        is_new: true,
      });

    if (insertError) {
      console.error('Failed to insert into projects:', insertError);
      return res.status(500).json({ error: 'Approved but failed to publish' });
    }
  }

  return res.status(200).json({ ok: true, action });
};
