import { MyMath } from './math';

import * as mocha from 'mocha';
import * as chai from 'chai';

const expect = chai.expect;
describe('My math library', () => {

  it('should be able to add things correctly' , () => {
    expect(MyMath.add(3,4)).to.equal(7);
  });

});

