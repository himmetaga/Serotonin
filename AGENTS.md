# Serotonin project instructions

## User decisions

- Build a premium, single-purchase, single-player iOS game. Multiplayer was explicitly canceled.
- The player is a courier inside a human, delivering specialized cargo to different regions to help that person experience happiness.
- Aim for Apple Design Awards quality through coherent art direction, immersive buttonless gameplay, compound missions, and satisfying skill-based combat. Never promise an award.
- Use Turkish for user-facing collaboration unless requested otherwise.
- Latest user decision: use Godot as the main engine and Blender for 3D models. Develop and playtest on Windows. Mac/iPhone validation is a final platform stage because the user has no Mac.
- Camera decision: third-person perspective following the courier from behind, replacing the earlier fixed orthographic camera. Keep single-finger controls usable with automatic camera assistance.

## Model delegation preference

- Latest user priority: tightly control credit consumption. This limits the earlier delegation preference below. Default to one economical worker when delegation is genuinely useful; do not automatically spawn a team or duplicate reviews. Never claim to have changed the current model without tool confirmation.
- Reserve Astra for consequential decisions and milestone reviews, not every iteration. Reuse existing outputs; avoid repeated full-family renders and unchanged test runs. Run verification proportionate to the actual change.
- Work in small, bounded increments. Obtain approval before expensive or broad work. The user going to sleep and saying the rest is up to us is not an unlimited spending budget or a request for recurring automation.
- The user explicitly authorized delegation and requested Astra as the director, with economical models doing bounded implementation work.
- Use available Astra capability for creative direction, consequential architecture decisions, and final quality review. Use available economical models (for example Luna for suitable simple work) for concrete, independently reviewable tasks.
- Give workers explicit scope, acceptance criteria, and disjoint file ownership. Review and verify their outputs before integrating.
- Avoid duplicating work or spawning agents for trivial work. Do not claim model switching, delegation, or reviews occurred unless tools confirm it. Disclose any unavailable capability.

## Design source

- Read SEROTONIN_CREATIVE_DIRECTION.md before implementation. Its section 1 records user decisions; the rest contains proposed design details, not already-approved requirements.
- For biomorphic/ethereal art briefs, Blender architecture, membrane/chitin materials, or visual quality reviews, read the project-local `.agents/skills/serotonin-biomorphic-art/SKILL.md` and its routed research reference. It records researched guidance, not installed external tools or completed art implementation.
- Preserve touch readability, single-finger usability, and accessibility. No permanently visible movement/attack buttons in the default gameplay layout; accessible pause/settings remain available.
- Validate controls and combat in Godot on Windows throughout development. Keep touch support and mobile budgets in scope. Mac/iPhone build, performance and touch validation are final platform gates; do not block Windows development on unavailable Apple hardware. Windows verification is not an iOS build or device test.
- Preserve prototypes/TouchGarden as an earlier Swift reference, not the main implementation. Author editable Blender sources separately from Godot runtime GLB assets.
