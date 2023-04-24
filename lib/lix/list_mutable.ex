defmodule Lix.ListMutable do
  import Lix.Math, only: [equal: 2]
  import Lix.List, only: [build: 2]
  def seqrem(_, _, list), do: list

  def rember(_, []), do: []
  def rember(a, [a | tail]) when is_atom(a), do: rember(a, tail)
  def rember(a, [head | tail]) when is_atom(head), do: [head | rember(a, tail)]
  def rember(a, [head | tail]), do: [rember(a, head) | rember(a, tail)]
  def rember(_, _, []), do: []

  def rember(f, a, [head | tail]) do
    case f.(a, head) do
      true -> tail
      false -> [head | rember(f, a, tail)]
    end
  end

  def rember(f) do
    fn
      _, [] ->
        []

      a, [head | tail] ->
        case f.(a, head) do
          true -> tail
          false -> [head | rember(f).(a, tail)]
        end
    end
  end

  def rember_f(a, list), do: insert_g(&seqrem/3).(nil, a, list)

  def insertR(_, _, []), do: []
  def insertR(new, old, [old | tail]) when is_atom(old), do: [old, new | insertR(new, old, tail)]
  def insertR(new, old, [head | tail]) when is_atom(head), do: [head | insertR(new, old, tail)]

  def insertR(new, old, [car = [_ | _] | tail]),
    do: [insertR(new, old, car) | insertR(new, old, tail)]

  def insertR(f) do
    fn
      _, _, [] ->
        []

      new, old, [head | tail] ->
        case f.(old, head) do
          true -> [old | [new | tail]]
          false -> [head | insertR(f).(new, old, tail)]
        end
    end
  end

  def insertL(_, _, []), do: []
  def insertL(new, old, [old | tail]) when is_atom(old), do: [new, old | insertL(new, old, tail)]
  def insertL(new, old, [head | tail]) when is_atom(head), do: [head | insertL(new, old, tail)]
  def insertL(new, old, [head | tail]), do: [insertL(new, old, head) | insertL(new, old, tail)]

  def insertL(f) do
    fn
      _, _, [] ->
        []

      new, old, [head | tail] = list ->
        case f.(old, head) do
          true -> [new | list]
          false -> [head | insertL(f).(new, old, tail)]
        end
    end
  end

  def seqL(new, old, list), do: [new, old | list]
  def seqR(new, old, list), do: [old, new | list]
  def seqS(new, _, list), do: [new | list]

  def insert_g(strategy) do
    fn
      _, _, [] -> []
      new, old, [old | tail] -> strategy.(new, old, tail)
      new, old, [head | tail] -> [head | insert_g(strategy).(new, old, tail)]
    end
  end

  def subst(_, _, []), do: []
  def subst(new, old, [old | tail]) when is_atom(old), do: [new | subst(new, old, tail)]
  def subst(new, old, [head | tail]) when is_atom(head), do: [head | subst(new, old, tail)]
  def subst(new, old, [head | tail]), do: [subst(new, old, head) | subst(new, old, tail)]
  def subst(new, old, list), do: insert_g(&seqS/3).(new, old, list)

  def subst2(_, _, _, []), do: []
  def subst2(new, o1, _, [o1 | tail]), do: [new, tail]
  def subst2(new, _, o2, [o2 | tail]), do: [new, tail]
  def subst2(new, o1, o2, [head | tail]), do: [head, subst2(new, o1, o2, tail)]

  def multirember(_, []), do: []
  def multirember(a, [a | tail]), do: multirember(a, tail)
  def multirember(a, [head | tail]), do: [head, multirember(a, tail)]

  def multirember(f) do
    fn
      _, [] ->
        []

      a, [head | tail] ->
        case f.(a, head) do
          true -> multirember(f).(a, tail)
          false -> [head | multirember(f).(a, tail)]
        end
    end
  end

  def multirember_eq, do: multirember(&equal/2)

  def multiremberT(f) do
    fn
      [] ->
        []

      [head | tail] ->
        case f.(head) do
          true -> multiremberT(f).(tail)
          false -> [head | multiremberT(f).(tail)]
        end
    end
  end

  def multirember_and_co(_, [], col), do: col.([], [])
  def multirember_and_co(a, [a | tail], col), do: multirember_and_co(a, tail, &col.(&1, [a | &2]))

  def multirember_and_co(a, [head | tail], col),
    do: multirember_and_co(a, tail, &col.([head | &1], &2))

  def multiinsertR(_, _, []), do: []
  def multiinsertR(new, old, [old | tail]), do: [old, new | multiinsertR(new, old, tail)]
  def muiltiinsertR(new, old, [head | tail]), do: [head | multiinsertR(new, old, tail)]

  def multiinsertL(_, _, []), do: []
  def multiinsertL(new, old, [old | tail]), do: [new, old | multiinsertL(new, old, tail)]
  def multiinsertL(new, old, [head | tail]), do: [head | multiinsertL(new, old, tail)]

  def multiinsertLR(_, _, _, []), do: []

  def multiinsertLR(new, oldl, oldr, [oldl | tail]) do
    [new | [oldl | multiinsertLR(new, oldl, oldr, tail)]]
  end

  def multiinsertLR(new, oldl, oldr, [oldr | tail]) do
    [oldr | [new | multiinsertLR(new, oldl, oldr, tail)]]
  end

  def multiinsertLR(new, oldl, oldr, [head | tail]) do
    [head | multiinsertLR(new, oldl, oldr, tail)]
  end

  def multiinsertLR(new, oldl, oldr, [_ | tail], col) do
    multiinsertLR(new, oldl, oldr, tail, col)
  end

  def multisubst(_, _, []), do: []
  def multisubst(new, old, [old | tail]), do: [new | multisubst(new, old, tail)]
  def multisubst(new, old, [head | tail]), do: [head | multisubst(new, old, tail)]

  def shift([[f1, f2], s2]), do: build(f1, build(f2, s2))
end
