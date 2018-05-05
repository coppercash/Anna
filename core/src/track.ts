
export interface Tracking 
{
  receiveResult(result :any) :void;
}

export namespace InPlaceTracker
{
  export type Receive = (result :any) => void;
}
export class InPlaceTracker implements Tracking 
{
  receive :InPlaceTracker.Receive;
  constructor(
    receive :InPlaceTracker.Receive
  ) {
    this.receive = receive;
  }
  receiveResult(
    result :any
  ) :void {
    this.receive(result);
  }
}

