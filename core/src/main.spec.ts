import { Manager as Anna } from './index';
import { InPlaceTracker as Tracker } from './track'
import { InPlaceLoader as Loader } from './load'

import * as mocha from 'mocha';
import * as chai from 'chai';
const expect = chai.expect;

describe('Anna', () => {

  it('should record event on root' , (done) => {
    let
    anna = new Anna(new Loader((match) => {
      match('/appear', (n) => { return n.events[0].properties.answer; })
    }));
    anna.tracker = new Tracker((result) => {
      expect(result).to.equal(42);
      done();
    });
    let 
    id = anna.nodeID(7, 'root');
    anna.registerNode(id);
    anna.recordEvent('appear', {answer: 42}, id);
  });

  it('should record event on sub node' , (done) => {
    let
    anna = new Anna(new Loader((match) => {
      match('/foo/bar/tap', (n) => { return n.events[0].properties.answer; })
    }));
    anna.tracker = new Tracker((result) => {
      expect(result).to.equal(43);
      done();
    });
    let 
    root = anna.nodeID(7, 'root');
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
    anna = new Anna(new Loader((match) => {
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
    root = anna.nodeID(7, 'root');
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

  it('should deregister node' , () => {
    let
    anna = new Anna(new Loader(() => {}));
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
    root = anna.nodeID(7, 'root');
    anna.registerNode(root);
    var
    parent = root;
    for (let 
      id of ids
    ) {
      anna.registerNode(id, parent);
      parent = id;
    }

    anna.deregisterNode(ids[1]);
    anna.registerNode(ids[3], ids[0]);
  });

});
