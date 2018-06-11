module.exports = function(dependency) {
    dependency.require = require;
    return require('../anna.bundle/index.js').Manager.run(dependency);
}
