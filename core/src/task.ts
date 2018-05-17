import * as Match from './match'
import * as Trie from './trie'

export namespace Loading
{
  export type Tasks = Match.Stage;
}
export interface Loading
{
  matchTasks(namePath :string[]) :Loading.Tasks
}

export class Tree extends Trie.Node<string, Loading.Tasks> {
}

