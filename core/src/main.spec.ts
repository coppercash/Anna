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
      match('/appear', (n) => { return n.earliestEvent().attributes.answer; })
    }));
    anna.tracker = new Tracker((result) => {
      expect(result).to.equal(42);
      done();
    });
    anna.registerNode(7, null, 'root');
    anna.recordEvent('appear', {answer: 42}, 7);
  });

  it('should record event on sub node' , (done) => {
    let
    anna = new Anna(new Loader((match) => {
      match('/foo/bar/tap', (n) => { return n.earliestEvent().attributes.answer; })
    }));
    anna.tracker = new Tracker((result) => {
      expect(result).to.equal(43);
      done();
    });
    anna.registerNode(7, null, 'root');
    anna.registerNode(77, 7, 'foo');
    anna.registerNode(777, 77, 'bar');
    anna.recordEvent('tap', {answer: 43}, 777);
  });

  it('should record event on non-absolute path' , (done) => {
    let
    anna = new Anna(new Loader((match) => {
      match('foo/bar/tap', (n) => { return n.earliestEvent().attributes.answer; })
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
    names = '/foo/bar/pass/foo/bar'
      .split('/')
      .slice(1);
    anna.registerNode(7, null, 'root');
    var
    parent = 7;
    var
    index = 70;
    for (let 
      name of names
    ) {
      anna.registerNode(index, parent, name);
      parent = index;
      index += 1;
    }
    anna.recordEvent('tap', {answer: 42}, 71);
    anna.recordEvent('tap', {answer: 24}, 74);
  });

  it('should deregister node' , () => {
    let
    anna = new Anna(new Loader(() => {}));
    let
    names = '/alpha/beta/delta/gamma'
      .split('/')
      .slice(1);
    anna.registerNode(7, null, 'root');
    var
    parent = 7;
    var
    index = 70;
    for (let 
      name of names
    ) {
      anna.registerNode(index, parent, name);
      parent = index;
      index += 1;
    }

    anna.deregisterNodes(71);
    anna.registerNode(73, 70, 'gamma');
  });

  it('should record event on reusable node' , (done) => {
    let
    anna = new Anna(new Loader((match) => {
      match('foo/tap', (n) => { return n.earliestEvent().attributes.answer; })
      match('foo/bar/tap', (n) => { return n.earliestEvent().attributes.answer; })
    }));
    var
    count = 0;
    anna.tracker = new Tracker((result) => {
      switch (count) {
        case 0:
          expect(result).to.equal(42);
          break;
        case 1:
          expect(result).to.equal(43);
          break;
        default:
          break;
      }
      count += 1;
      if (count == 2) {
        done();
      }
    });
    anna.registerNode(7, null, 'root');
    anna.registerNode([70, 700], 7, 'foo');
    anna.registerNode([80, 800, 8000], [70, 700], 'bar');
    anna.recordEvent('tap', {answer: 42}, [70, 700]);
    anna.recordEvent('tap', {answer: 43}, [80, 800, 8000]);
  });

  it('should deregister reusable node' , () => {
    let
    anna = new Anna(new Loader(() => {}));
    anna.registerNode(7, null, 'root');
    anna.registerNode([70, 700], 7, 'foo')
    anna.registerNode([80, 800, 8000], [70, 700], 'bar');
    anna.deregisterNodes(70);
    anna.registerNode([80, 800, 8000], 7, 'bar');
  });

  it('should reload tasks if configured' , (done) => {
    let
    config = {debug: true};
    var
    time = 0;
    let
    anna = new Anna(new Loader((match) => {
      let
      delta = time;
      match('/appear', () => { 
        return 42 + delta; 
      })
    }), config);
    anna.tracker = new Tracker((result) => {
      switch (time) {
        case 0:
          expect(result).to.equal(42);
          break
        case 1:
          expect(result).to.equal(43);
          break
        case 2:
          expect(result).to.equal(44);
          break
      }
      time += 1;
      if (!(time < 3)) {
        done();
      }
    });
    for (var i = 0; i < 3; i += 1) {
      anna.registerNode(7, null, 'root');
      anna.recordEvent('appear', {}, 7);
      anna.deregisterNodes(7);
    }
  });

  it('should not reload tasks if not configured' , (done) => {
    let
    config = {debug: false};
    var
    time = 0;
    let
    anna = new Anna(new Loader((match) => {
      let
      delta = time;
      match('/foo/appear', () => { return 42 + delta; })
    }), config);
    anna.tracker = new Tracker((result) => {
      switch (time) {
        case 0:
        case 1:
        case 2:
          expect(result).to.equal(42);
      }
      time += 1;
      if (!(time < 3)) {
        done();
      }
    });
    anna.registerNode(7, null, 'root');
    for (var i = 0; i < 3; i += 1) {
      anna.registerNode(8, 7, 'foo');
      anna.recordEvent('appear', {}, 8);
      anna.deregisterNodes(8);
    }
  });

  it('should drop old tasks before reloading' , (done) => {
    let
    config = {debug: true};
    var
    loaded = 0;
    let
    anna = new Anna(new Loader((match) => {
      switch(loaded) {
        case 1: 
        case 2: 
        case 5: 
          {
            match('foo/appear', (node) => { return 42; });
            match('foo/bar/appear', (node) => { 
              return node.latestEvent().attributes.value;
            })
          } break;
        default:
          break;
      }
      loaded += 1;
    }), config);
    var
    received = 0;
    anna.tracker = new Tracker((result) => {
      received += 1;
      if (result == 'done') {
        expect(received).to.equal(3);
        done();
      }
    });
    anna.registerNode(7, null, 'root');

    anna.registerNode(8, 7, 'foo');
    anna.recordEvent('appear', {value: 0}, 8);

    anna.registerNode(9, 8, 'bar');
    anna.recordEvent('appear', {value: 1}, 9);

    anna.deregisterNodes(8);
    anna.registerNode(8, 7, 'foo');
    anna.recordEvent('appear', {value: 2}, 8);

    anna.registerNode(9, 8, 'bar');
    anna.recordEvent('appear', {value: 3}, 9);

    anna.deregisterNodes(9);
    anna.registerNode(9, 8, 'bar');
    anna.recordEvent('appear', {value: 'done'}, 9);
  });

  it('should load tasks according to namespace' , (done) => {
    let
    anna = new Anna(new Loader((match, namePath) => {
      let
      namespace = namePath.join('.');
      switch(namespace) {
        case 'Lib.Alpha': 
          {
            match('foo/appear', (node) => { return namespace; });
          } break;
        case 'Lib.Beta': 
          {
            match('foo/bar/appear', (node) => { return namespace; });
          } break;
        default:
          break;
      }
    }));
    var
    received = new Array<any>();
    anna.tracker = new Tracker((result) => {
      received.push(result);
      if (received.length == 2) {
        expect(received[0]).to.equal('Lib.Alpha');
        expect(received[1]).to.equal('Lib.Beta');
        done();
      }
    });
    anna.registerNode(7, null, 'root');
    anna.registerNode(8, 7, 'foo', undefined, 'nonsence');
    anna.registerNode(9, 8, 'bar', undefined, 'nonsence');
    anna.recordEvent('appear', {}, 8);
    anna.recordEvent('appear', {}, 9);
    anna.deregisterNodes(8);
    anna.registerNode(8, 7, 'foo', undefined, 'Lib.Alpha');
    anna.registerNode(9, 8, 'bar', undefined, 'Lib.Beta');
    anna.recordEvent('appear', {}, 8);
    anna.recordEvent('appear', {}, 9);
  });
});
