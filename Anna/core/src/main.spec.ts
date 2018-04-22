import { Anna, Tracking } from './main';

import * as mocha from 'mocha';
import * as chai from 'chai';
const expect = chai.expect;

class 
Tracker implements Tracking {
  callback :(any) => void;
  constructor(callback) {
    this.callback = callback;
  }
  receiveResult(result :any) {
    this.callback(result);
  }
}

describe('Anna', () => {

  it('should record event on root' , (done) => {
    let
    anna = new Anna();
    anna.tracker = new Tracker((result) => {
      expect(result.answer).to.equal(42);
      done();
    });
    let 
    id = anna.rootNodeID(7);
    anna.registerNode(id);
    anna.recordEvent({answer: 42}, id);
  });

  it('should record event on sub node' , (done) => {
    let
    anna = new Anna();
    anna.tracker = new Tracker((result) => {
      expect(result.answer).to.equal(42);
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
    anna.recordEvent({answer: 42}, bar);
  });

});
