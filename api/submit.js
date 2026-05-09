// api/submit.js
// Handles new project submissions from the public form.
// Validates input, checks honeypot, inserts into submissions table.

const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { name, description, category, url, tags, twitter, contract, email, _hp } = req.body;

  // Honeypot check — bots fill hidden fields, humans don't
  if (_hp) {
    return res.status(200).json({ ok: true }); // Silently accept to fool bots
  }

  // Server-side validation
  const errors = [];
  if (!name || name.trim().length < 2 || name.trim().length > 60) errors.push('name');
  if (!description || description.trim().length < 10 || description.trim().length > 120) errors.push('description');
  if (!category || !['DeFi','NFT','Bridge','Tool','DAO','Social','Infra'].includes(category)) errors.push('category');
  if (!url || !/^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/.test(url.trim())) errors.push('url');
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) errors.push('email');

  if (errors.length) {
    return res.status(400).json({ error: 'Validation failed', fields: errors });
  }

  // Clean and sanitise inputs
  const cleanTags = Array.isArray(tags)
    ? tags.map(t => t.trim().slice(0, 20)).filter(Boolean).slice(0, 3)
    : [];

  const { error: dbError } = await supabase
    .from('submissions')
    .insert({
      name: name.trim().slice(0, 60),
      description: description.trim().slice(0, 120),
      category,
      url: url.trim().toLowerCase().replace(/^https?:\/\//, ''),
      tags: cleanTags,
      twitter: twitter ? twitter.trim().slice(0, 30) : null,
      contract: contract ? contract.trim().slice(0, 42) : null,
      email: email ? email.trim().toLowerCase() : null,
    });

  if (dbError) {
    console.error('Supabase insert error:', dbError);
    return res.status(500).json({ error: 'Failed to save submission' });
  }

  // Send email notification to admin (if Resend is configured)
  if (process.env.RESEND_API_KEY) {
    try {
      await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: 'X1 Directory <noreply@yourdomain.com>',
          to: process.env.ADMIN_EMAIL,
          subject: `New submission: ${name}`,
          text: `A new project has been submitted for review.\n\nName: ${name}\nCategory: ${category}\nURL: ${url}\nEmail: ${email}\n\nReview it in the admin panel.`,
        }),
      });
    } catch (e) {
      console.error('Email notification failed:', e);
      // Don't fail the request just because email failed
    }
  }

  return res.status(200).json({ ok: true });
};
