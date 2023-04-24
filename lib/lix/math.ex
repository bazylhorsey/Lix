defmodule Lix.Math do
  def add(n, m), do: n + m

  def sub(n, 0), do: n
  def sub(n, m), do: sub(n, m - 1) - 1

  def addtup([]), do: 0
  def addtup([head | tail]), do: head + addtup(tail)
  def addtup([], []), do: []
  def addtup(t1, []), do: t1
  def addtup([], t2), do: t2
  def addtup([h1 | t1], [h2 | t2]), do: [h1 + h2 | addtup(t1, t2)]

  def times(n, m), do: n * m

  def greaterthan(0, 0), do: false
  def greaterthan(0, _), do: false
  def greaterthan(_, 0), do: true
  def greaterthan(a, b), do: greaterthan(a - 1, b - 1)

  def lessthan(0, 0), do: false
  def lessthan(_, 0), do: false
  def lessthan(0, _), do: true
  def lessthan(a, b), do: lessthan(a - 1, b - 1)

  def equal(n, n), do: true
  def equal(_, _), do: false

  def pow(_, 0), do: 1
  def pow(base, exponent), do: base * pow(base, exponent - 1)

  def divide(a, b) when a < b, do: 0
  def divide(a, b), do: 1 + divide(a - b, b)

  def pick(1, [head | _]), do: head
  def pick(n, [_ | tail]), do: pick(n - 1, tail)

  def size([]), do: 0
  def size([_ | tail]), do: 1 + size(tail)

  def one(1), do: true
  def one(_), do: false

  def nonums([]), do: []
  def nonums([head | tail]) when is_number(head), do: nonums(tail)
  def nonums([head | tail]), do: [head | nonums(tail)]

  def allnums([]), do: []
  def allnums([head | tail]) when is_number(head), do: [head | nonums(tail)]
  def allnums([_ | tail]), do: allnums(tail)

  def equan(a, a), do: true
  def equan(_, _), do: false

  def occur(_, []), do: 0
  def occur(a, [a | tail]) when is_atom(a), do: 1 + occur(a, tail)
  def occur(a, [head | tail]) when is_atom(head), do: occur(a, tail)
  def occur(a, [head | tail]) when is_list(head), do: occur(a, head) + occur(a, tail)
end
