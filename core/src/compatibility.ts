
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
  return haystack.indexOf(haystack, haystack.length - needle.length) !== -1;
}

