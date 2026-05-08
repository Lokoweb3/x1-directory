-- X1 Directory — Seed Data
-- Run this after schema.sql to populate the directory with initial projects.
-- Safe to re-run: deletes existing seed rows first using their known names.

DELETE FROM projects WHERE name IN (
  'X1 Swap','XBridge','X1 Lend','PixelX','X1 DAO',
  'NodeWatch','X1 Analytics','X1 RPC','GlitchMint','StackX'
);

INSERT INTO projects (name, description, category, url, tags, twitter, icon, verified, featured, is_new) VALUES
  ('X1 Swap',      'Native DEX for swapping tokens on X1 with low fees and deep liquidity.',           'DeFi',   'x1swap.io',         '{"DEX","AMM"}',       '@x1swap',      '⚡', true,  true,  false),
  ('XBridge',      'Trustless cross-chain bridge connecting X1 to Ethereum and BNB Chain.',            'Bridge', 'xbridge.finance',   '{"Bridge","EVM"}',    '@xbridge',     '⇄', true,  true,  false),
  ('X1 Lend',      'Permissionless lending and borrowing protocol with real-yield mechanics.',         'DeFi',   'x1lend.xyz',        '{"Lending"}',         NULL,           '◐', false, true,  false),
  ('PixelX',       'Generative on-chain NFT collection with fully stored artwork and royalties.',      'NFT',    'pixelx.art',        '{"PFP","On-chain"}',  '@pixelxnft',   '◆', false, false, false),
  ('X1 DAO',       'Governance protocol for community-led decisions across the X1 ecosystem.',         'DAO',    'x1dao.org',         '{"Governance"}',      '@x1dao',       '⬡', true,  true,  false),
  ('NodeWatch',    'Real-time validator and node monitoring dashboard with uptime alerts.',            'Tool',   'nodewatch.x1',      '{"Monitoring"}',      NULL,           '⊙', false, false, false),
  ('X1 Analytics', 'On-chain analytics, contract explorer, and address activity dashboard.',           'Tool',   'analytics.x1',      '{"Explorer","Data"}', '@x1analytics', '▦', true,  true,  false),
  ('X1 RPC',       'Public and premium RPC node infrastructure for X1 with 99.9% uptime SLA.',         'Infra',  'rpc.x1chain.io',    '{"RPC","Nodes"}',     NULL,           '▣', true,  true,  false),
  ('GlitchMint',   'NFT minting launchpad with allowlist tools and reveal mechanics for creators.',    'NFT',    'glitchmint.xyz',    '{"Launchpad"}',       '@glitchmint',  '✦', false, false, true),
  ('StackX',       'Smart contract templates, deployment tooling, and developer SDK for X1.',          'Infra',  'stackx.build',      '{"SDK","Dev"}',       '@stackxbuild', '⬢', false, false, true);
