match(
  '/master/ana-appeared',
  function (node) { return { action: 'appeared', id: node.path }; }
);
match(
  'master/tableView/cell/did-select',
  function (node) { return { action: 'selected', id: node.path }; }
);
