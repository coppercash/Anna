import { Anna, Tracking, Loading } from './main';

import * as mocha from 'mocha';
import * as chai from 'chai';
const expect = chai.expect;

type Receive = (result :any) => void;
class Tracker implements Tracking 
{
  receive :Receive;
  constructor(
    receive :Receive
  ) {
    this.receive = receive;
  }
  receiveResult(
    result :any
  ) :void {
    this.receive(result);
  }
}

type Load = (path :string, manager :Anna) => void;
class Loader implements Loading 
{
  load :Load;
  constructor(
    load :Load = null
  ) {
    this.load = load;
  }
  matchTasks(
    namespace :string, 
    manager :Anna
  ) {
    let
    load = this.load;
    if (!(load)) { return; }
    load(namespace, manager);
  }
}
  

describe('Anna', () => {

  it('should record event on root' , (done) => {
    let
    anna = new Anna(new Loader((namespace, manager) => {
      let
      match = manager.task.match;
      match('/appear', (n) => { return n.events[0].properties.answer; })
    }));
    anna.tracker = new Tracker((result) => {
      expect(result).to.equal(42);
      done();
    });
    let 
    id = anna.rootNodeID(7);
    anna.registerNode(id);
    anna.recordEvent('appear', {answer: 42}, id);
  });

  it('should record event on sub node' , (done) => {
    let
    anna = new Anna(new Loader((namespace, manager) => {
      let
      match = manager.task.match;
      match('/foo/bar/tap', (n) => { return n.events[0].properties.answer; })
    }));
    anna.tracker = new Tracker((result) => {
      expect(result).to.equal(43);
      done();
    });
    let 
    root = anna.rootNodeID(7);
    anna.registerNode(root);
    let
    foo = anna.nodeID(77, 'foo');
    anna.registerNode(foo, root);
    let
    bar = anna.nodeID(777, 'bar');
    anna.registerNode(bar, foo);
    anna.recordEvent('tap', {answer: 43}, bar);
  });

  it('should record event on non-absolute path' , (done) => {
    let
    anna = new Anna(new Loader((namespace, manager) => {
      let
      match = manager.task.match;
      match('foo/bar/tap', (n) => { return n.events[0].properties.answer; })
    }));
    var
    results = new Array<number>();
    anna.tracker = new Tracker((result) => {
      results.push(result);
      if (results.length == 2) {
        expect(results.reduce((s, x) => { return s + x; }, 0)).to.equal(42 + 24);
        done();
      }
    });
    var
    index = 0;
    let
    ids = '/foo/bar/pass/foo/bar'
      .split('/')
      .slice(1)
      .map((x) => {
        return anna.nodeID(index++, x);
      });
    let 
    root = anna.rootNodeID(7);
    anna.registerNode(root);
    var
    parent = root;
    for (let 
      id of ids
    ) {
      anna.registerNode(id, parent);
      parent = id;
    }
    anna.recordEvent('tap', {answer: 42}, ids[1]);
    anna.recordEvent('tap', {answer: 24}, ids[4]);
  });

  it('should unregister node' , () => {
    let
    anna = new Anna(new Loader());
    var
    index = 0;
    let
    ids = '/alpha/beta/delta/gamma'
      .split('/')
      .slice(1)
      .map((x) => {
        return anna.nodeID(index++, x);
      });
    let 
    root = anna.rootNodeID(7);
    anna.registerNode(root);
    var
    parent = root;
    for (let 
      id of ids
    ) {
      anna.registerNode(id, parent);
      parent = id;
    }

    anna.unregisterNode(ids[1]);
    anna.registerNode(ids[3], ids[0]);
  });

});
