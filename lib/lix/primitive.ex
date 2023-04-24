defmodule Lix.Primitive do
  import Lix.List,
    only: [
      build: 2
    ]

  def cdr([_ | tail]), do: tail

  def car([head | _]), do: head

  def cons(head, tail), do: [head | tail]

  def null?([]), do: true
  def null?(_), do: false

  def eq?(a, a) when is_atom(a), do: true
  def eq?(a, b) when is_atom(a) and is_atom(b), do: false

  def combinator(le) do
    (fn f -> f.(f) end).(fn f ->
      le.(fn x -> f.(f).(x) end)
    end)
  end

  def eternity(x), do: eternity(x)

  def new_entry(l, r), do: build(l, r)
  def extend_table(e, table), do: [e | table]

  def lookup_in_entry(name, [keys, values], error) do
    lookup_in_entry_help(name, keys, values, error)
  end

  defp lookup_in_entry_help(name, [], _, error) do
    error.(name)
  end

  defp lookup_in_entry_help(name, [name | _], [value | _], _), do: value

  defp lookup_in_entry_help(name, [_ | keys], [_ | values], error) do
    lookup_in_entry_help(name, keys, values, error)
  end

  def lookup_in_table(name, [], tf), do: tf.(name)

  def lookup_in_table(name, [entry | t_tail], tf) do
    lookup_in_entry(
      name,
      entry,
      fn n -> lookup_in_table(n, t_tail, tf) end
    )
  end

  def const_action(n, _) when is_number(n), do: n
  def const_action(b, _) when is_boolean(b), do: b
  def const_action(p, _), do: [:primitive, p]

  def quote_action([_label, body], _), do: body

  def identifier_action(e, table) do
    lookup_in_table(e, table, fn n -> "#{n} not found" end)
  end

  def lambda_action([_type, formals, body], table) do
    [:non_primitive, [table, formals, body]]
  end

  def atom_to_action(e) do
    case is_member(e, primitives) do
      true -> &Lix.Primitive.const_action/2
      false -> &Lix.Primitive.identifier_action/2
    end
  end

  def application_action([f | args], table) do
    appli(
      meaning(f, table),
      evlis(args, table)
    )
  end

  def list_to_action([:quote | _]), do: &Lix.Primitive.quote_action/2
  def list_to_action([:lambda | _]), do: &Lix.Primitive.lambda_action/2
  def list_to_action([:cond | _]), do: &Lix.Primitive.cond_action/2

  def list_to_action(_) do
    &Lix.Primitive.application_action/2
  end

  def expression_to_action(e = [_ | _]), do: list_to_action(e)
  def expression_to_action(e), do: atom_to_action(e)

  def meaning(e, table), do: expression_to_action(e).(e, table)

  def cond_action([_ | cond_lines], table), do: evcon(cond_lines, table)
  defp evcon([[:else, answer]], table), do: meaning(answer, table)

  defp evcon([[question, answer] | remaining_questions], table) do
    case meaning(question, table) do
      true -> meaning(answer, table)
      false -> evcon(remaining_questions, table)
    end
  end

  defp evcon([], _), do: raise("no questions found")

  def evlis([], _), do: []

  def evlis([head | tail], table) do
    [meaning(head, table) | evlis(tail, table)]
  end

  def apply_primitive(:eq?, [v, v]), do: true
  def apply_primitive(:eq?, [_, _]), do: false
  def apply_primitive(:cons, [head, tail]), do: [head | tail]
  def apply_primitive(:car, [[head | _]]), do: head
  def apply_primitive(:cdr, [[_ | tail]]), do: tail
  def apply_primitive(:null?, [[] | _]), do: true
  def apply_primitive(:null?, _), do: false
  def apply_primitive(:atom?, [e]), do: is_atom(e) || is_number(e)
  def apply_primitive(:zero?, [0]), do: true
  def apply_primitive(:zero?, _), do: false
  def apply_primitive(:add1, [n]), do: n + 1
  def apply_primitive(:sub1, [n]), do: n - 1
  def apply_primitive(:*, [a, b]), do: a * b
  def apply_primitive(:number?, [n]), do: is_number(n)
  def apply_primitive(n, _), do: raise("unknown primitive #{n}")

  def apply_closure([table, formals, body], vals) do
    meaning(body, [[formals, vals] | table])
  end

  def appli([:primitive, f_rep], vals) do
    apply_primitive(f_rep, vals)
  end

  def appli([:non_primitive, f_rep], vals) do
    apply_closure(f_rep, vals)
  end

  def value(e), do: meaning(e, [])

  defp primitives do
    [
      true,
      false,
      :cons,
      :car,
      :cdr,
      :null?,
      :atom?,
      :zero?,
      :add1,
      :sub1,
      :*,
      :number?,
      :eq?
    ]
  end

  defp is_member(_, []), do: false
  defp is_member(e, [e | _]), do: true
  defp is_member(e, [_ | tail]), do: is_member(e, tail)
end
