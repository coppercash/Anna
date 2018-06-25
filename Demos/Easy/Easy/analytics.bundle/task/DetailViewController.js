match(
  'detail/ana-updated',
  function (node) { return 'Displayed detail of ' + node.latestEvent().attributes.value; }
);
