module.exports = function(dependency) {
    dependency.require = require;
    return require('anna').Manager.run(dependency);
}
