import * as Path from 'path'

export default class
Anna 
{
    registerRootNode(locator :Path.NodeLocator) 
    {
        let
        registered = nodes.nodeByLocator(locator)
        if (registered) {
            return
        }
        let
        node = Path.Node(
            name: locator.name, 
            parent: null
        )
        let
        matching = loader.allNodesByLoading()
        node.addMatchingNodes(matching)
        nodes.addNodeByLocator(locator, node)
    }

    registerNode(
        locator :Path.NodeLocator, 
        parentLocator :Path.NodeLocator
    )
    {
        let
        registered = nodes.nodeByLocator(locator)
        if (registered) {
            return
        }
        let 
        parent = nodes.nodeByLocator(parentLocator)
        if (!(parent)) {
            throw Error('Can not find registered parent node for node named ' + locator.name)
        }
        let
        node = Path.Node(
            name: locator.name, 
            parent: parent
        )
        parent.setChildByName(node.name, node)
        let
        matchings = parent.matchingNodesWithName(node.name)
        node.addMatchingNodes(matchings)
        nodes.addNodeByLocator(locator, node)
    }

    unregisterNode(locator :Path.NodeLocator)
    {
        nodes.removeNodeByLocator(locator)
    }

    recordEvent(
        properties :object, 
        locator :Path.NodeLocator
    )
    {
        let
        node = nodes.nodeByLocator(locator)
        if (!(node)) {
            throw Error('Cannot recod on unregistered node named ' + locator.name)
        }
        node.recordEvent(properties)
        let
        tasks = node.matchingEventTasks()
        if (!(tasks && tasks.count > 0)) {
            throw Error('Node named ' + node.name + 'is not registered with any events')
        }
        for (task in tasks) {
            let
            result = task.resultByMapping(node)
            track.receiveAnalyticsResult(result)
        }
    }
}

