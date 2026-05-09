// api/verify.js
// Toggles the verified status of a project.
// Requires a valid Supabase session token.

const { createClient } = require('@supabase/supabase-js');

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Unauthorised' });

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY,
    { global: { headers: { Authorization: `Bearer ${token}` } } }
  );

  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) return res.status(401).json({ error: 'Invalid session' });

  const { projectId } = req.body;
  if (!projectId) return res.status(400).json({ error: 'projectId required' });

  const adminClient = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

  const { data: project, error: fetchError } = await adminClient
    .from('projects')
    .select('verified')
    .eq('id', projectId)
    .single();

  if (fetchError || !project) return res.status(404).json({ error: 'Project not found' });

  const { error: updateError } = await adminClient
    .from('projects')
    .update({ verified: !project.verified })
    .eq('id', projectId);

  if (updateError) return res.status(500).json({ error: 'Update failed' });

  return res.status(200).json({ ok: true, verified: !project.verified });
};
