-- Research-to-practice library metadata and deterministic content seed.
-- Source assets: shared/content/meditation-techniques.json, audio-library.json,
-- and alexandria-integration.md. Alexandria remains an editorial source map only
-- for v1 and is not queried by the app at runtime.

ALTER TABLE practices
  ADD COLUMN IF NOT EXISTS source_id text,
  ADD COLUMN IF NOT EXISTS source_kind text
    CHECK (source_kind IS NULL OR source_kind IN ('legacy_curriculum','meditation_technique','audio_library')),
  ADD COLUMN IF NOT EXISTS layers text[],
  ADD COLUMN IF NOT EXISTS tags text[],
  ADD COLUMN IF NOT EXISTS use_cases text[],
  ADD COLUMN IF NOT EXISTS evidence_level text
    CHECK (evidence_level IS NULL OR evidence_level IN ('strong','moderate','low','theoretical')),
  ADD COLUMN IF NOT EXISTS risk_level text
    CHECK (risk_level IS NULL OR risk_level IN ('very_low','low','moderate','high')),
  ADD COLUMN IF NOT EXISTS risk_note text,
  ADD COLUMN IF NOT EXISTS icon_name text,
  ADD COLUMN IF NOT EXISTS subtitle text,
  ADD COLUMN IF NOT EXISTS is_advanced boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS audio_source text
    CHECK (audio_source IS NULL OR audio_source IN ('ios_bundle','supabase_storage','remote_url')),
  ADD COLUMN IF NOT EXISTS sort_order int;

UPDATE practices
SET
  source_id = COALESCE(source_id, 'legacy:' || id::text),
  source_kind = COALESCE(source_kind, 'legacy_curriculum'),
  layers = COALESCE(layers, CASE WHEN category IS NULL THEN NULL ELSE ARRAY[category]::text[] END),
  sort_order = COALESCE(sort_order, week_number * 100),
  audio_source = CASE
    WHEN audio_source IS NOT NULL THEN audio_source
    WHEN audio_path IS NOT NULL AND audio_path ~ '^https?://' THEN 'remote_url'
    WHEN audio_path IS NOT NULL THEN 'supabase_storage'
    ELSE NULL
  END
WHERE source_id IS NULL OR source_kind IS NULL OR layers IS NULL OR sort_order IS NULL OR audio_source IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS practices_source_id_uidx
  ON practices(source_id)
  WHERE source_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS practices_layers_gin_idx ON practices USING gin(layers);
CREATE INDEX IF NOT EXISTS practices_tags_gin_idx ON practices USING gin(tags);
CREATE INDEX IF NOT EXISTS practices_sort_order_idx ON practices(sort_order);

INSERT INTO practices (title, body_text, transcript, audio_path, has_audio, week_number, duration_minutes, category, emotional_intensity, published, source_id, source_kind, layers, tags, use_cases, evidence_level, risk_level, risk_note, icon_name, subtitle, is_advanced, audio_source, sort_order) VALUES
  ('Mantra Meditation', 'Key concept: Mantra as vehicle, not focus point

Tradition/source frame: Transcendental Meditation

Suggested frequency: 1-2x daily', NULL, NULL, false, NULL, 20, 'self_regulation', NULL, true, 'technique:mantra-meditation', 'meditation_technique', ARRAY['self_regulation']::text[], NULL, ARRAY['morning_practice', 'stress_reduction', 'focus']::text[], 'strong', 'very_low', NULL, 'waveform.path', 'TM-style repetition', false, NULL, 1000),
  ('Breath Awareness', 'Key concept: Observe breath without controlling

Tradition/source frame: Vipassana / Mindfulness

Suggested frequency: daily', NULL, NULL, false, NULL, 20, 'self_regulation', NULL, true, 'technique:breath-awareness', 'meditation_technique', ARRAY['self_regulation']::text[], NULL, ARRAY['beginner_friendly', 'anchor_practice', 'stress_reduction']::text[], 'strong', 'very_low', NULL, 'wind', 'Mindfulness of breathing', false, NULL, 1001),
  ('Body Scan', 'Key concept: Notice sensations without changing them

Tradition/source frame: MBSR (Jon Kabat-Zinn)

Clinical basis: Mindfulness-Based Stress Reduction (MBSR)', NULL, NULL, false, NULL, 20, 'self_regulation', NULL, true, 'technique:body-scan', 'meditation_technique', ARRAY['self_regulation']::text[], NULL, ARRAY['trauma_informed', 'somatic_awareness', 'sleep_preparation', 'anxiety_reduction']::text[], 'strong', 'very_low', NULL, 'figure.stand', 'Somatic awareness', false, NULL, 1002),
  ('Loving-Kindness', 'Key concept: Cultivate feeling of warmth, not perfect wording

Tradition/source frame: Theravada Buddhism / Metta

Bridges Layer 1 (self-compassion) and Layer 2 (extending warmth to partner/others)', NULL, NULL, false, NULL, 20, 'self_regulation', NULL, true, 'technique:loving-kindness', 'meditation_technique', ARRAY['self_regulation', 'co_regulation']::text[], NULL, ARRAY['relationship_repair', 'self_compassion', 'co_regulation_prep', 'emotional_healing']::text[], 'strong', 'very_low', NULL, 'heart.fill', 'Metta meditation', false, NULL, 1003),
  ('Guided Visualization', 'Key concept: Engage all senses in mental space

Tradition/source frame: General meditation / therapeutic imagery

Layer 4 connection: visualizing one''s highest self / contribution (Neville Goddard territory)', NULL, NULL, false, NULL, 15, 'self_regulation', NULL, true, 'technique:guided-visualization', 'meditation_technique', ARRAY['self_regulation', 'agency']::text[], NULL, ARRAY['goal_visualization', 'identity_work', 'relaxation', 'creativity']::text[], 'moderate', 'very_low', NULL, 'sparkles', 'Mental imagery practice', false, NULL, 1004),
  ('Walking Meditation', 'Key concept: Lift, move, place awareness

Tradition/source frame: Zen / Theravada

Layer 3 connection: naturally practiced in community / group walk settings', NULL, NULL, false, NULL, 20, 'self_regulation', NULL, true, 'technique:walking-meditation', 'meditation_technique', ARRAY['self_regulation', 'community']::text[], NULL, ARRAY['accessible', 'community_practice', 'outdoor_mindfulness', 'movement_integration']::text[], 'moderate', 'very_low', NULL, 'figure.walk', 'Mindful movement', false, NULL, 1005),
  ('Eye-Rolling Sleep', 'Key concept: Tire eye muscles to signal brain to wind down

Tradition/source frame: Modern / viral (HuffPost, Instagram)

Best used: Before sleep

Evidence note: Theoretical plausibility via oculocardiac reflex / vagus nerve. No direct clinical validation.', NULL, NULL, false, NULL, 15, 'self_regulation', NULL, false, 'technique:eye-rolling-sleep', 'meditation_technique', ARRAY['self_regulation']::text[], NULL, ARRAY['sleep_onset', 'evening_routine', 'accessible']::text[], 'theoretical', 'very_low', 'Theoretical plausibility via oculocardiac reflex / vagus nerve. No direct clinical validation.', 'eye.circle', 'Ocular relaxation for sleep', true, NULL, 1006),
  ('Pineal Gland Breath', 'Key concept: Rhythmic breathing + crown attention for pineal stimulation

Tradition/source frame: Yogic breathwork (Joe Dispenza lineage)

Safety note: Stop if dizzy. Empty stomach recommended.', NULL, NULL, false, NULL, 20, 'self_regulation', NULL, false, 'technique:pineal-gland-breath', 'meditation_technique', ARRAY['self_regulation']::text[], NULL, ARRAY['advanced_practice', 'energy_work', 'consciousness_exploration']::text[], 'low', 'low', 'Stop if dizzy. Empty stomach recommended.', 'brain.head.profile', 'Energy activation breathwork', true, NULL, 1007),
  ('Vortex Breath', 'Key concept: Descending Fibonacci sequence compresses breath rhythm into a spiraling vortex that resets the nervous system

Tradition/source frame: Modern breathwork (Fibonacci-based)

Pattern: Inhale/exhale pairs: 13s → 8s → 5s → 3s → 2s → 1s

Also available as haptic-guided timer in Dharma app breathing patterns

Safety note: Stop if dizzy. Practice seated.', NULL, NULL, false, NULL, 5, 'self_regulation', NULL, false, 'technique:vortex-breath', 'meditation_technique', ARRAY['self_regulation']::text[], NULL, ARRAY['quick_reset', 'nervous_system_regulation', 'transitions', 'short_practice']::text[], 'low', 'very_low', 'Stop if dizzy. Practice seated.', 'hurricane', 'Fibonacci descending breathwork', true, NULL, 1008),
  ('Yoga Nidra', 'Key concept: Conscious deep-relaxation hovering between waking and sleeping

Tradition/source frame: Yogic tradition (Satyananda Saraswati lineage)', NULL, NULL, false, NULL, 45, 'self_regulation', NULL, true, 'technique:yoga-nidra', 'meditation_technique', ARRAY['self_regulation']::text[], NULL, ARRAY['deep_relaxation', 'sleep_preparation', 'trauma_healing', 'restoration']::text[], 'moderate', 'very_low', NULL, 'moon.zzz', 'Yogic sleep', false, NULL, 1009),
  ('Trataka', 'Key concept: Steady gazing at a single point to strengthen concentration and calm mental chatter

Tradition/source frame: Hatha Yoga (Shatkarma purification practice)', NULL, NULL, false, NULL, 20, 'self_regulation', NULL, false, 'technique:trataka', 'meditation_technique', ARRAY['self_regulation']::text[], NULL, ARRAY['concentration_training', 'ritual_practice', 'focus_building']::text[], 'low', 'very_low', NULL, 'flame', 'Candle gazing meditation', true, NULL, 1010),
  ('HRV and the autonomic nervous system', 'Topic: HRV and the autonomic nervous system

Use when: science_foundation, self_regulation_education, onboarding

Tags: hrv, nervous_system, science, foundation', NULL, 'Learn/hrv_nervous_system.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:hrv-nervous-system', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['hrv', 'nervous_system', 'science', 'foundation']::text[], ARRAY['science_foundation', 'self_regulation_education', 'onboarding']::text[], NULL, NULL, NULL, 'book.closed', 'Audio lesson', false, 'ios_bundle', 2000),
  ('Resonance frequency breathing (HRV coherence)', 'Topic: Resonance frequency breathing (HRV coherence)

Use when: coherent_breathing, stress_reduction, hrv_training

Tags: breathing, hrv, coherence, practice', NULL, 'Learn/resonance_breathing.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:resonance-breathing', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['breathing', 'hrv', 'coherence', 'practice']::text[], ARRAY['coherent_breathing', 'stress_reduction', 'hrv_training']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2001),
  ('Box breathing (4-4-4-4 pattern)', 'Topic: Box breathing (4-4-4-4 pattern)

Use when: acute_stress, nervous_system_reset, beginner_friendly

Tags: breathing, box, military, beginner', NULL, 'Learn/box_breathing.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:box-breathing', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['breathing', 'box', 'military', 'beginner']::text[], ARRAY['acute_stress', 'nervous_system_reset', 'beginner_friendly']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2002),
  ('Nadi Shodhana (alternate nostril breathing)', 'Topic: Nadi Shodhana (alternate nostril breathing)

Use when: balance, focus, pre_meditation

Tags: pranayama, yogic, breathing, balance', NULL, 'Learn/alternate_nostril.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:alternate-nostril', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['pranayama', 'yogic', 'breathing', 'balance']::text[], ARRAY['balance', 'focus', 'pre_meditation']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2003),
  ('MBSR body scan meditation', 'Topic: MBSR body scan meditation

Use when: somatic_awareness, trauma_informed, relaxation

Tags: somatic, mbsr, body, relaxation', NULL, 'Learn/body_scan.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:body-scan', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['somatic', 'mbsr', 'body', 'relaxation']::text[], ARRAY['somatic_awareness', 'trauma_informed', 'relaxation']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2004),
  ('Metta / loving-kindness meditation', 'Topic: Metta / loving-kindness meditation

Use when: self_compassion, relational_repair, co_regulation_prep

Tags: metta, compassion, heart, relational', NULL, 'Learn/loving_kindness.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:loving-kindness', 'audio_library', ARRAY['self_regulation', 'co_regulation']::text[], ARRAY['metta', 'compassion', 'heart', 'relational']::text[], ARRAY['self_compassion', 'relational_repair', 'co_regulation_prep']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2005),
  ('Co-regulation — the science of nervous system synchrony between people', 'Topic: Co-regulation — the science of nervous system synchrony between people

Use when: partner_practice, relational_healing, clinical_education

Tags: co_regulation, nervous_system, relational, pairs, layer2_featured', NULL, 'Learn/co_regulation.m4a', true, NULL, NULL, 'co_regulation', NULL, true, 'audio:co-regulation', 'audio_library', ARRAY['co_regulation']::text[], ARRAY['co_regulation', 'nervous_system', 'relational', 'pairs', 'layer2_featured']::text[], ARRAY['partner_practice', 'relational_healing', 'clinical_education']::text[], NULL, NULL, NULL, 'book.closed', 'Audio lesson', false, 'ios_bundle', 2006),
  ('Partner synchronized breathing — breathing in unison with another person', 'Topic: Partner synchronized breathing — breathing in unison with another person

Use when: partner_practice, couple_therapy, group_practice

Tags: synchronized, partner, breathing, co_regulation, layer2_featured', NULL, 'Learn/synchronized_breathing.m4a', true, NULL, NULL, 'co_regulation', NULL, true, 'audio:synchronized-breathing', 'audio_library', ARRAY['co_regulation']::text[], ARRAY['synchronized', 'partner', 'breathing', 'co_regulation', 'layer2_featured']::text[], ARRAY['partner_practice', 'couple_therapy', 'group_practice']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2007),
  ('Using breath as an anchor for present-moment awareness', 'Topic: Using breath as an anchor for present-moment awareness

Use when: mindfulness_foundation, anxiety, grounding

Tags: anchor, mindfulness, grounding, foundation', NULL, 'Learn/breath_as_anchor.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:breath-as-anchor', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['anchor', 'mindfulness', 'grounding', 'foundation']::text[], ARRAY['mindfulness_foundation', 'anxiety', 'grounding']::text[], NULL, NULL, NULL, 'book.closed', 'Audio lesson', false, 'ios_bundle', 2008),
  ('Richard Davidson''s 4 pillars of wellbeing (awareness, connection, insight, purpose)', 'Topic: Richard Davidson''s 4 pillars of wellbeing (awareness, connection, insight, purpose)

Use when: wellbeing_framework, science_foundation, layer4_bridge

Tags: davidson, neuroscience, pillars, wellbeing, purpose', NULL, 'Learn/davidson_four_pillars.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:davidson-four-pillars', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['davidson', 'neuroscience', 'pillars', 'wellbeing', 'purpose']::text[], ARRAY['wellbeing_framework', 'science_foundation', 'layer4_bridge']::text[], NULL, NULL, NULL, 'book.closed', 'Audio lesson', false, 'ios_bundle', 2009),
  ('Cycling through Davidson''s 4 pillars as a daily practice', 'Topic: Cycling through Davidson''s 4 pillars as a daily practice

Use when: daily_practice, purpose, identity

Tags: davidson, pillars, purpose, identity, practice', NULL, 'Learn/four_pillars_cycle.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:four-pillars-cycle', 'audio_library', ARRAY['self_regulation', 'agency']::text[], ARRAY['davidson', 'pillars', 'purpose', 'identity', 'practice']::text[], ARRAY['daily_practice', 'purpose', 'identity']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2010),
  ('Open awareness / choiceless awareness meditation', 'Topic: Open awareness / choiceless awareness meditation

Use when: advanced_practice, expanded_consciousness, non_dual

Tags: awareness, choiceless, advanced, non_dual', NULL, 'Learn/open_awareness.m4a', true, NULL, NULL, 'self_regulation', NULL, false, 'audio:open-awareness', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['awareness', 'choiceless', 'advanced', 'non_dual']::text[], ARRAY['advanced_practice', 'expanded_consciousness', 'non_dual']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', true, 'ios_bundle', 2011),
  ('Morning intention-setting and centering practice', 'Topic: Morning intention-setting and centering practice

Use when: morning_routine, intention, grounding

Tags: morning, intention, ritual, centering', NULL, 'Learn/morning_entrance.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:morning-entrance', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['morning', 'intention', 'ritual', 'centering']::text[], ARRAY['morning_routine', 'intention', 'grounding']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2012),
  ('Evening reflection and return to center', 'Topic: Evening reflection and return to center

Use when: evening_routine, reflection, completion

Tags: evening, reflection, ritual, completion', NULL, 'Learn/evening_return.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:evening-return', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['evening', 'reflection', 'ritual', 'completion']::text[], ARRAY['evening_routine', 'reflection', 'completion']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2013),
  ('Establishing a stable, grounded meditation posture', 'Topic: Establishing a stable, grounded meditation posture

Use when: beginner_foundation, somatic, posture

Tags: posture, grounding, beginner, foundation', NULL, 'Learn/finding_your_seat.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:finding-your-seat', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['posture', 'grounding', 'beginner', 'foundation']::text[], ARRAY['beginner_foundation', 'somatic', 'posture']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2014),
  ('The dose-response relationship in meditation practice — how much, how often', 'Topic: The dose-response relationship in meditation practice — how much, how often

Use when: habit_building, science_foundation, motivation

Tags: dose_response, science, habit, consistency', NULL, 'Learn/dose_response.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:dose-response', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['dose_response', 'science', 'habit', 'consistency']::text[], ARRAY['habit_building', 'science_foundation', 'motivation']::text[], NULL, NULL, NULL, 'book.closed', 'Audio lesson', false, 'ios_bundle', 2015),
  ('ACT cognitive defusion — placing thoughts on leaves floating downstream', 'Topic: ACT cognitive defusion — placing thoughts on leaves floating downstream

Use when: cognitive_defusion, act_technique, thought_distancing

Tags: act, defusion, thoughts, acceptance, clinical', NULL, 'Learn/leaves_on_stream.m4a', true, NULL, NULL, 'self_regulation', NULL, true, 'audio:leaves-on-stream', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['act', 'defusion', 'thoughts', 'acceptance', 'clinical']::text[], ARRAY['cognitive_defusion', 'act_technique', 'thought_distancing']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', false, 'ios_bundle', 2016),
  ('Hu mantra toning — the ancient Sufi sound current practice', 'Topic: Hu mantra toning — the ancient Sufi sound current practice

Use when: mantra, sound_healing, spiritual_practice

Tags: hu, mantra, sufi, toning, sound_current', NULL, 'Learn/hu_tone.m4a', true, NULL, NULL, 'self_regulation', NULL, false, 'audio:hu-tone', 'audio_library', ARRAY['self_regulation']::text[], ARRAY['hu', 'mantra', 'sufi', 'toning', 'sound_current']::text[], ARRAY['mantra', 'sound_healing', 'spiritual_practice']::text[], NULL, NULL, NULL, 'waveform', 'Guided audio practice', true, 'ios_bundle', 2017)
ON CONFLICT (source_id) WHERE source_id IS NOT NULL DO UPDATE SET
  title = EXCLUDED.title,
  body_text = EXCLUDED.body_text,
  transcript = EXCLUDED.transcript,
  audio_path = EXCLUDED.audio_path,
  has_audio = EXCLUDED.has_audio,
  week_number = EXCLUDED.week_number,
  duration_minutes = EXCLUDED.duration_minutes,
  category = EXCLUDED.category,
  emotional_intensity = EXCLUDED.emotional_intensity,
  published = EXCLUDED.published,
  source_kind = EXCLUDED.source_kind,
  layers = EXCLUDED.layers,
  tags = EXCLUDED.tags,
  use_cases = EXCLUDED.use_cases,
  evidence_level = EXCLUDED.evidence_level,
  risk_level = EXCLUDED.risk_level,
  risk_note = EXCLUDED.risk_note,
  icon_name = EXCLUDED.icon_name,
  subtitle = EXCLUDED.subtitle,
  is_advanced = EXCLUDED.is_advanced,
  audio_source = EXCLUDED.audio_source,
  sort_order = EXCLUDED.sort_order;
