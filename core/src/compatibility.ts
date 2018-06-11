
export function copy_of_set<Element>(
  set :Set<Element>
) : Set<Element> {
  let
  copy = new Set();
  set.forEach(function(e) { copy.add(e); })
  return copy;
}

export function array_from_set<Element>(
  set :Set<Element>
) : Array<Element> {
  var
  array = new Array<Element>();
  set.forEach(function(e) { array.push(e); })
  return array;
}

export function string_starts_with(
  haystack :string,
  needle :string
) : boolean {
  return haystack.lastIndexOf(needle, 0) === 0;
}

export function string_ends_with(
  haystack :string,
  needle :string
) : boolean {
  return haystack.indexOf(needle, haystack.length - needle.length) !== -1;
}

export function object_assign(
  target :{ [key :string] : any },
  source :{ [key :string] : any }
) : object {
  for (let 
    key of Object.keys(source)
  ) {
    target[key] = source[key];
  }
  return target;
}
export function object_remove_all(
  target :{ [key :string] : any }
) : void {
  for (let 
    key of Object.keys(target)
  ) {
    delete target[key];
  }
}

