# SM_SmartChests

Scrap Mechanic mod for smarter pipe inventory routing.

## What this mod changes

The vanilla/old `FindContainerToCollectTo` logic sends items to the **first** connected container that can accept them.

SM_SmartChests replaces that behavior with a **priority-based selection** system:
- it checks all connected containers,
- scores each valid destination,
- and sends the item to the highest-priority match.

This lets you build sorted storage networks instead of relying on pipe/chest placement order.

## Installation

1. Back up your original file:
   - `...\Scrap Mechanic\Survival\Scripts\game\util\pipes.lua`
2. Replace it with this repository's `pipes.lua`.
3. Start the game.

## In-game behavior (priority order)

When an item moves through a pipe network, the destination chest is selected in this order:

1. **Dedicated/special containers** (highest)
   - Gas container for gas
   - Battery container for batteries
   - Water container for water
   - Chemical container for chemicals
   - Fertilizer container for fertilizer
   - Seed/ammo style dedicated containers where mapped by the mod

2. **Single-item painted chests**
   - Chests painted in the **lightest or darkest palette colors** act as single-item filters.
   - They accept only the item already in slot 1.
   - If empty, they accept the first inserted item and become filtered to that item afterward.

3. **Category-painted chests**
   - Chests painted in specific 3rd-row (2nd-darkest) colors accept category-matching items:
   - **Grey**: metal-based blocks
   - **Green**: wood-based blocks
   - **Yellow**: stone/glass/tile style blocks
   - **Lime**: carpet/plastic/bubblewrap style blocks
   - **Blue**: small/normal pipes and fittings
   - **Red**: vehicle parts
   - **Orange**: logic parts

4. **Normal chests** (lowest)
   - Any chest with other colors works as a fallback destination.

## How to use it in game

1. Build your pipe network as usual.
2. Place dedicated containers for consumables (gas, battery, water, etc.) where needed.
3. Paint sorting chests:
   - use lightest/darkest colors for single-item bins,
   - use category colors for grouped storage,
   - leave one or more normal chests as overflow.
4. Feed items into the network.
5. The mod auto-routes items by priority, so your storage stays organized without manual transfer.

## Compared to the old behavior

### Old/vanilla routing
- First valid chest in traversal order wins.
- Pipe layout and placement order heavily affect where items end up.
- Sorting is inconsistent unless you micro-manage network structure.

### SM_SmartChests routing
- Best valid chest by rule priority wins.
- Chest paint and container type define destination behavior.
- Stable, predictable sorting with less maintenance as your base grows.
