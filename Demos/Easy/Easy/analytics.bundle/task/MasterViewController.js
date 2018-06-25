match(
  '/master/ana-appeared',
  function (node) { return node.path; }
);
match(
  'master/tableView/cell/did-select',
  function (node) { return 'Selected ' + node.latestValue('text'); }
);
