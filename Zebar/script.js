export function focusWorkspace(event, context) {
    // console.log('Focus button clicked!', event, context);
    const id = event.target.id;
    context.providers.glazewm.focusWorkspace(id);
  }
  
  export function toggleTilingDirection(event, context) {
    context.providers.glazewm.toggleTilingDirection();
  }