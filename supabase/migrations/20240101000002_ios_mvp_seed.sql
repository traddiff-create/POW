-- iOS MVP Seed — 8-week curriculum + 5 civic modules
-- Run after migration 001

-- =====================================================================
-- PRACTICES (8 weeks × 1 somatic practice per week)
-- =====================================================================

INSERT INTO practices (title, body_text, week_number, duration_minutes, category, published) VALUES

('5-Minute Grounding and Body Awareness',
'Find a comfortable seat or lie down. Begin by placing both feet flat on the floor.

Take three slow breaths, letting each exhale be longer than the inhale.

Notice five things you can feel — the weight of your body, the texture of fabric, the temperature of the air.

Scan slowly from the soles of your feet up through your legs, hips, belly, chest, shoulders, and crown. Notice sensation without trying to change it.

When you find tension or holding, breathe gently toward it. Let the breath be an act of curiosity, not correction.

Rest here for two minutes, arriving fully in this body, this moment.',
1, 5, 'self_regulation', true),

('Breath as Anchor',
'This practice uses the breath as a portable regulation tool.

Sit comfortably. Exhale completely to begin.

Inhale for a count of 4. Hold at the top for a count of 4. Exhale for a count of 6. Hold at the bottom for a count of 2.

Repeat this cycle 8 times, adjusting the counts to what your body accepts without strain.

After the final round, breathe naturally and notice what has shifted. The nervous system responds to extended exhales as a signal of safety.',
2, 7, 'self_regulation', true),

('Listening to Receive',
'This practice builds the capacity to be fully present with another — a foundation for co-regulation.

Find a partner if available, or practice with a recorded voice. If alone, bring to mind someone you trust.

For three minutes: listen without preparing your response. Notice when you begin to form a reply and gently return to receiving.

After listening, pause for 30 seconds before responding. Notice what you genuinely want to say when you''re not in a rush to fill silence.

Reflection: What did it feel like to truly receive someone?',
3, 10, 'co_regulation', true),

('Mirroring and Attunement',
'Regulation is contagious — this practice makes that tangible.

Sit across from a partner. One person leads slow movements for two minutes: lifting a hand, tilting the head, shifting weight. The other mirrors without anticipating.

Switch roles.

Together: notice what it felt like to be followed exactly. Notice what it felt like to follow.

This is attunement — the body-to-body resonance that underlies trust.',
4, 12, 'co_regulation', true),

('Contribution Inventory',
'This practice locates your current capacity for community contribution — without judgment.

Take 10 minutes to write or reflect on three questions:

1. What do I have in surplus right now? (Energy, skill, time, knowledge, presence)
2. What do I genuinely enjoy giving?
3. What would I contribute if I trusted it was needed?

Do not filter for what sounds good. Write what''s true. Community begins with honest accounting of what''s available.',
5, 10, 'community', true),

('Finding Your Edge',
'Agency requires knowing your limits — not as failure, but as information.

Reflect in writing or quiet thought:

Where in your life do you feel like you''re operating inside your actual values?
Where are you operating outside them — going along with something that costs you?

Choose one situation where you''ve been saying yes when you mean maybe. Write a single sentence that names what you actually want.

You don''t have to act on it today. But knowing it precisely builds capacity for agency.',
6, 8, 'agency', true),

('Mapping Your Civic Ecosystem',
'Where do decisions about your life get made — and who is in those rooms?

Draw or write a simple map:
- Your neighborhood or block
- Your municipality
- Your school board, park district, library board, transit authority

For each: who decides, when they meet, and whether you''ve ever attended.

This is not an assignment to show up. It is the groundwork for knowing what showing up would mean.',
7, 15, 'civic_engagement', true),

('Integration: What Piece Are You?',
'This closing practice synthesizes the spiral.

Sit quietly for 5 minutes with the question: What piece of the whole are you?

Not what you should be. Not what you''re working toward. What piece are you, right now, today — with your specific capacity, specific edges, specific gifts?

Write one paragraph. Don''t edit it for beauty. Let it be true.',
8, 8, 'civic_engagement', true);

-- =====================================================================
-- CIVIC LESSONS (5 modules)
-- =====================================================================

INSERT INTO civic_lessons (title, body_text, reflection_prompt, suggested_action, integration_question, estimated_minutes, order_index, published) VALUES

('What Local Civic Life Is',
'Most people believe civic life means voting every four years. This module reframes that.

Local civic life is the ongoing practice of showing up where decisions about shared resources are made: zoning boards, city councils, school boards, park districts, library committees, neighborhood associations.

These are not spaces reserved for the politically interested or professionally connected. They are literally open to the public. Most of them have public comment periods where any resident can speak for 3 minutes.

The barrier is rarely access. It is almost always the feeling that it''s not for you, or that it won''t matter. Both are learned — and both can be unlearned.',
'What beliefs do you carry about who civic life is for? Where did those beliefs come from?',
'Find the meeting schedule for one local body — your city council, school board, or park district — and note when it meets next.',
'How does this connect to the community layer of the spiral — what you contribute to systems larger than yourself?',
20, 1, true),

('How Decisions Move',
'Local decisions follow predictable paths. Understanding the path is power.

Most decisions move through: staff recommendation → committee review → public comment → board vote → implementation.

The best time to influence a decision is before it reaches a board vote — during the staff recommendation or committee phase. By the time it''s on a meeting agenda, most of the work is already done.

This means: reading meeting agendas in advance, submitting written comments, attending committee hearings rather than just final votes, and building relationships with staff — not just elected officials.',
'Think of a local decision that affected you. At what point did you become aware of it? What point would have been most useful to engage?',
'Subscribe to the agenda mailing list for one local body. Most have them and most are free.',
'Where in your own life do you make decisions in ways others only see at the final stage? What would it mean to open earlier parts of that process?',
25, 2, true),

('How to Attend Without Overwhelm',
'Public meetings can be dysregulating — long, procedurally dense, and sometimes deliberately confusing.

Strategies for attending without burning out:

Go once before you need to. Attend a meeting on a topic you''re neutral about, just to learn the format.

Bring a grounding anchor — a physical object, a friend, a note that reminds you why you came.

Set a time limit. You don''t have to stay for the whole meeting. Public comment often happens at the start; you can leave after.

Write your comment in advance. Reading from a written statement reduces the cognitive load of speaking in public.

Debrief afterward. Civic engagement is a regulated activity, not a performative one.',
'What''s the most dysregulating part of the idea of attending a public meeting for you?',
'Write a 3-sentence public comment on any topic you care about — without planning to deliver it. Practice the form.',
'How does the nervous system regulation work from earlier in the program support your capacity for civic engagement?',
20, 3, true),

('Relational Advocacy',
'Policy changes through relationship, not just argument.

Relational advocacy means building ongoing connection with decision-makers — not just showing up once to deliver a position.

This looks like: introducing yourself to a council member or school board member before you need something from them. Attending town halls without an agenda. Writing a note of appreciation when a decision went well. Being known before you become a constituent with a complaint.

People with power respond differently to someone they know versus a stranger. Relationship doesn''t guarantee alignment — but it creates the conditions for real dialogue.',
'Is there a local elected official or staff member whose work intersects with something you care about? Do they know your name?',
'Write a brief, genuine email to one local official — not asking for anything, just introducing yourself and naming one thing about their work you appreciate.',
'What does it mean to invest in a relationship for collective benefit rather than personal gain?',
25, 4, true),

('Choosing Your Piece',
'You cannot do all of civic life. This module is about choosing deliberately.

After completing the spiral, you have a clearer sense of your actual capacity: what you have in surplus, what costs you, and what you genuinely care about.

Civic engagement works best when it''s aligned with that knowledge — when you''re contributing from abundance rather than grinding from obligation.

Your piece might be: attending one school board meeting per quarter. Writing letters to the editor twice a year. Hosting a neighbor conversation about a local issue. Running for a local appointed board. Or simply staying informed and voting in every election, including primaries.

None of these is insufficient. The question is: which one is yours?',
'If you could make one contribution to your civic community that felt sustainable and true to who you are, what would it be?',
'Name your piece in one sentence. Write it somewhere you''ll see it.',
'How does your piece connect to the rest of the spiral — to your self-regulation, your co-regulation, your community, your agency?',
20, 5, true);
