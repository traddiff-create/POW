# Alexandria Integration

Alexandria is a personal digital library indexing 29,000+ files across the `/Applications/Apps/` and `~/Documents/` directories. For A Piece of Whole, it serves as the AI knowledge brain — a queryable corpus of consciousness philosophy, breathwork research, clinical protocols, and wellness science.

## What's in Alexandria

| Collection | Files | Layer Relevance |
|-----------|-------|----------------|
| Walter Russell | 44 entries (21 books, 12 audio, 9 research) | Layer 4 — philosophical foundation for "a piece of whole" (each individual as expression of cosmic unity) |
| Neville Goddard | 165 files | Layer 1 + 4 — inner work, imagination, identity assumption |
| Breathwork research | `breathwork-master.md`, TRE, MBCT protocols | Layer 1 + 2 |
| Wellness science | HRV, MBSR, somatic research | Layer 1 |
| Co-regulation theory | Clinical protocols | Layer 2 |

## How to Query

### Via CLI (macOS)
```bash
# Search for a topic
alexandria search "co-regulation nervous system"

# Browse by subject
alexandria browse "Walter Russell"

# Find related entries
alexandria show <id>        # get entry detail
alexandria related <id>     # find related entries

# Subject-filtered search
alexandria search "breathing" --subject "Health & Wellness"
```

### Via REST API (port 8642)
The Alexandria dashboard exposes a REST API when running:

```bash
# Start dashboard
alexandria dashboard --port 8642

# Search
curl "http://localhost:8642/api/search?q=co-regulation&limit=5"

# Browse subjects
curl "http://localhost:8642/api/subjects"

# Get entry
curl "http://localhost:8642/api/entries/<id>"

# Knowledge graph
curl "http://localhost:8642/api/graph?subject=Walter+Russell&limit=20"
```

### Via MCP Server (Claude integration)
The `AlexandriaMCP` Swift target is a fully implemented MCP server with 11 tools:

| Tool | Purpose |
|------|---------|
| `alexandria_search` | FTS5 full-text search with BM25 ranking |
| `alexandria_fuzzy_search` | LIKE-based fuzzy search |
| `alexandria_browse` | List entries by subject |
| `alexandria_subjects` | All subjects with counts |
| `alexandria_tags` | All tags with counts |
| `alexandria_show` | Entry detail (UUID, tags, subjects, media) |
| `alexandria_stats` | Library statistics |
| `alexandria_related` | Related entries by shared subjects/tags |
| `alexandria_graph` | Knowledge graph (nodes + edges) |
| `alexandria_gaps` | Gap analysis |
| `alexandria_snapshot` | URL → local markdown |

Add to `.mcp.json` to use in Claude sessions:
```json
{
  "mcpServers": {
    "alexandria": {
      "command": "/path/to/.build/release/AlexandriaMCP"
    }
  }
}
```

## Example AI Queries for A Piece of Whole

These are the kinds of questions Alexandria can answer in real-time for app users or facilitators:

```
"What does Walter Russell say about individual purpose?"
→ Search Alexandria for Russell entries tagged Agency/Philosophy

"I'm feeling disconnected from my partner — what do the research files say?"
→ Search breathwork-master.md and co_regulation theory files

"What is the scientific basis for synchronized breathing?"
→ FTS5 search across research corpus for HRV synchrony evidence

"What practices connect to the idea of being a piece of the whole?"
→ Graph traversal: Russell cosmogony → individual purpose → civic contribution
```

## Layer-to-Subject Mapping

| Layer | Alexandria Subjects to Query |
|-------|----------------------------|
| 1 — Self Regulation | "Health & Wellness", "Breathwork", "Mindfulness", "MBSR", "Somatic" |
| 2 — Co-Regulation | "Co-Regulation", "Relational Health", "Nervous System" |
| 3 — Community | "Community", "Group Practice", "Facilitation" |
| 4 — Agency | "Walter Russell", "Neville Goddard", "Personal Development", "Purpose" |
| 5 — Civic Engagement | "Civic Education", "Democracy", "Community Organizing" |

## Remote Access

Alexandria is accessible at `library.traddiff.com` via Cloudflare tunnel with Basic Auth. This enables the app to query the live library remotely without requiring local setup.

See `MEMORY.md` entry: `[Alexandria Remote](memory/alexandria-remote-access.md)` for connection details.

## Architecture Note

Alexandria uses:
- **SQLite FTS5** with porter stemming for full-text search
- **BM25 ranking** for relevance scoring
- **Ollama / nomic-embed-text** for semantic search (local vector embeddings)
- **Knowledge graph** via CrossRef + GraphEngine for relationship traversal
- **Dewey classification** + custom A00/B00 for consciousness/metaphysics topics

The FTS5 stemming means `"regulate"` matches `"regulation"`, `"regulated"`, `"regulating"` — important for wellness vocabulary.
