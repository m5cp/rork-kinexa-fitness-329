# Add Liquid Glass styling to tab bar and buttons

## What will change

**Tab bar**

- Replace the current solid white tab bar with a floating, translucent Liquid Glass bar
- Rounded pill/capsule shape that hovers above content instead of a hard rectangular dock locked to the bottom edge
- Soft blur that lets the screen content subtly show through
- The selected tab gets a gentle tinted glass highlight; other tabs stay clear
- Smooth springy bounce when switching tabs (kept from current behavior)
- Coach chat floating button restyled as a circular liquid glass bubble that sits next to / above the bar

**Buttons across the app**

- Primary action buttons (Generate, Save, Continue, Start, etc.) get a prominent liquid glass look with a soft tinted glow
- Secondary buttons (icon-only buttons in headers, toolbar items, quick actions) get a clear glass capsule/circle treatment
- Tappable cards keep their existing card style (glass is for navigation/controls, not content) but gain a subtle press-in liquid response
- All glass buttons get the interactive shimmer effect — they react to touch with a fluid highlight

**Fallback for older devices**

- On iOS 18, buttons and the tab bar fall back to the current ultra-thin material look so nothing breaks
- Liquid Glass only activates on iOS 26+

## What stays the same

- Tab order, icons, labels, and navigation behavior
- All existing screens, colors, and content layouts
- The coach chat button still floats in the same spot, just restyled

