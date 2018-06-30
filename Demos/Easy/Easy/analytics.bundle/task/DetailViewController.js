match(
  'detail/detailDescriptionButton/touch-up-inside',
  function (node) { return {
    action: 'tapped',
    id: node.path,
    content: node.parentNode.latestValue('titleLabel.text')
  }; }
);
