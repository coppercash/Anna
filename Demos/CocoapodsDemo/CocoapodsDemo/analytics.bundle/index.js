module.exports = function (taskModulePath, inject, receive, config) {
    return require('../anna.bundle/index.js').Manager.execute(taskModulePath, inject, require, receive, config);
};
