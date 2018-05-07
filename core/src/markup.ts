
export interface Markable
{
  markup(
    indent :string
  ) :string
}

export namespace Markable
{
  export type Properties = { [name: string]: any; };
}

export function markup(
  name :string,
  properties :Markable.Properties = {},
  children :Markable[] = [],
  indent :string = '',
  closed :boolean = false
) :string
{
  var
  buffer = '';
  for (let
    key in properties
  ) {
    buffer = `${ buffer } ${ key }="${ properties[key] }"`;
  }
  buffer = `${ indent }<${ name }${ buffer }`;

  if (children.length == 0) {
    buffer = `${ buffer }${ closed ? ' />' : '>' }`
    return buffer;
  }

  buffer = `${ buffer }>`;
  let
  childIndent = `${ indent }  `;
  for (let
    child of children
  ) {
    let
    marked = child.markup(childIndent);
    if (!(marked)) { continue; }
    buffer = buffer + '\n' + marked;
  }

  if (closed) {
    buffer = buffer + '\n' + `${ indent }</${ name }>`;
  }

  return buffer;
}

export class NameMarker implements Markable
{
  name :string;
  constructor(
    name :string
  ) {
    this.name = name;
  }

  markup(
    indent :string = ''
  ) :string {
    return markup(this.name, {}, [], indent, true);
  }
}

export class ArrayMarker extends NameMarker
{
  elements :Markable[];
  constructor(
    name :string,
    elements :Markable[]
  ) {
    super(name);
    this.elements = elements; 
  }

  markup(
    indent :string = ''
  ) :string {
    let
    name = this.name, elements = this.elements;
    return markup(name, { length: elements.length }, elements, indent, true);
  }
}

export class ObjectMarker extends NameMarker
{
  properties :Markable.Properties;
  children :Markable[];
  constructor(
    name :string,
    properties :Markable.Properties,
    children :Markable[]
  ) {
    super(name);
    this.properties = properties;
    this.children = children;
  }

  markup(
    indent :string = ''
  ) :string {
    let
    name = this.name, properties = this.properties, children = this.children;
    return markup(this.name, properties, children, indent, true);
  }
}
