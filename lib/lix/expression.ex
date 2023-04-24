defmodule Lix.Expr do
  import Lix.Math, only: [pow: 2, add: 2, times: 2]

  def numbered([left, operator, right]) do
    numbered(left) && valid_operator(operator) && numbered(right)
  end

  def numbered(n), do: is_number(n)

  def atom_to_function(:+), do: &add/2
  def atom_to_function(:*), do: &times/2

  def operator_for([_, :+, _]), do: :+
  def operator_for([_, :*, _]), do: :*
  def operator_for([_, :^, _]), do: :^

  defp valid_operator(:+), do: true
  defp valid_operator(:*), do: true
  defp valid_operator(:^), do: true
  defp valid_operator(_), do: false

  def value([left, :+, right]), do: value(left) + value(right)
  def value([left, :*, right]), do: value(left) * value(right)
  def value([left, :^, right]), do: pow(value(left), value(right))
  def value(n) when is_number(n), do: n

  def value([_ | _] = nexp) do
    atom_to_function(operator_for(nexp)).(
      value(first_sub_expression(nexp)),
      value(second_sub_expression(nexp))
    )
  end

  def value(nexp), do: nexp

  def generic_value(n) when is_number(n), do: n

  def generic_value([_, _, _] = aexp) do
    case operator_for(aexp) do
      :+ -> first_sub_expression(aexp) + second_sub_expression(aexp)
      :* -> first_sub_expression(aexp) * second_sub_expression(aexp)
      :^ -> pow(first_sub_expression(aexp), second_sub_expression(aexp))
    end
  end

  def first_sub_expression([sub, _, _]), do: generic_value(sub)
  def second_sub_expression([_, _, sub]), do: generic_value(sub)

  def sero([]), do: true
  def sero(_), do: false

  def edd1(list), do: [[] | list]

  def zub1([_ | tail]), do: tail

  def sadd(n, m) do
    cond do
      sero(m) -> n
      true -> edd1(sadd(n, zub1(m)))
    end
  end
end
