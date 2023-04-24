defmodule Lix.List do
  import Lix.Math, only: [pick: 2]

  def lat([]), do: true
  def lat([[_ | _] | _]), do: false
  def lat([_ | t]), do: lat(t)

  def member(_, []), do: false
  def member(a, [a | _]) when is_atom(a), do: true
  def member(a, [head | tail]) when is_atom(head), do: member(a, tail)
  def member(a, [head | tail]), do: member(a, head) || member(a, tail)

  def leftmost([head | _]) when is_atom(head), do: head
  def leftmost([head | _]), do: leftmost(head)

  def firsts([]), do: []
  def firsts([[head | _] | tail]), do: [head | firsts(tail)]

  def eqlist([], []), do: true
  def eqlist(_, []), do: false
  def eqlist([], _), do: false
  def eqlist([h | t1], [h | t2]) when is_atom(h), do: eqlist(t1, t2)
  def eqlist([h1 | _], [h2 | _]) when is_atom(h1) and is_atom(h2), do: false
  def eqlist([h1 | t1], [h2 | t2]), do: eqlist(h1, h2) && eqlist(t1, t2)

  def evens_only([]), do: []
  def evens_only([head = [_ | _] | tail]), do: [evans_only(head) | evens_only(tail)]
  def evans_only([head | tail]) when rem(head, 2) == 0, do: [head | evens_only(tail)]
  def evans_only([_ | tail]), do: evens_only(tail)
  def evens_only([], col), do: col.([], 1, 0)

  def evens_only([head = [_ | _] | tail], col) do
    evens_only(
      head,
      fn h_res, h_prod, h_sum ->
        evens_only(
          tail,
          fn t_res, t_prod, t_sum ->
            col.([h_res | t_res], h_prod * t_prod, h_sum + t_sum)
          end
        )
      end
    )
  end

  def evens_only([head | tail], col) when rem(head, 2) == 0 do
    evens_only(
      tail,
      fn res, prod, sum ->
        col.([head | res], head * prod, head + sum)
      end
    )
  end

  def evens_only([head | tail], col) do
    evens_only(tail, fn res, prod, sum ->
      col.(res, prod, sum + head)
    end)
  end

  def looking(a, lat), do: keep_looking(a, pick(1, lat), lat)

  defp keep_looking(a, sorn, lat) when is_number(sorn) do
    keep_looking(a, pick(sorn, lat), lat)
  end

  defp keep_looking(a, a, _), do: true
  defp keep_looking(_, _, _), do: false

  def is_set([]), do: true

  def is_set([head | tail]) do
    case member(head, tail) do
      true -> false
      false -> is_set(tail)
    end
  end

  def makeset([]), do: []

  def makeset([head | tail]) do
    case member(head, tail) do
      true -> makeset(tail)
      false -> [head | makeset(tail)]
    end
  end

  def is_subset([], _), do: true

  def is_subset([head | tail], set) do
    case member(head, set) do
      true -> is_subset(tail, set)
      false -> false
    end
  end

  def eqset(s1, s2), do: is_subset(s1, s2) && is_subset(s2, s1)

  def has_intersect([], _), do: false

  def has_intersect([head | tail], set) do
    case member(head, set) do
      true -> true
      false -> has_intersect(tail, set)
    end
  end

  def intersect([], _), do: []

  def intersect([head | tail], set) do
    case member(head, set) do
      true -> [head | intersect(tail, set)]
      false -> intersect(tail, set)
    end
  end

  def union([], set), do: set

  def union([head | tail], set) do
    case member(head, set) do
      true -> union(tail, set)
      false -> [head | union(tail, set)]
    end
  end

  def intersectall([head | []]), do: head
  def intersectall([head | tail]), do: intersect(head, intersectall(tail))

  def is_pair([_, _]), do: true
  def is_pair(_), do: false

  def first([head | _]), do: head

  def second([_, head | _]), do: head

  def third([_, _, head | _]), do: head

  def build(s1, s2), do: [s1, s2]

  def is_fun(list), do: firsts(list) |> is_set

  def revrel([]), do: []
  def revrel([[head1, head2] | tail]), do: [[head2, head1] | revrel(tail)]

  def is_fullfun(f), do: revrel(f) |> is_fun

  def eq_c(a), do: fn x -> x == a end
end
