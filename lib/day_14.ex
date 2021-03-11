defmodule Day14 do
  @moduledoc """
  --- Day 14: Space Stoichiometry ---

  As you approach the rings of Saturn, your ship's low fuel indicator turns on.
  There isn't any fuel here, but the rings have plenty of raw material.
  Perhaps your ship's Inter-Stellar Refinery Union brand nanofactory can turn these raw materials into fuel.

  You ask the nanofactory to produce a list of the reactions it can perform that are relevant to this process (your puzzle input).
  Every reaction turns some quantities of specific input chemicals into some quantity of an output chemical.
  Almost every chemical is produced by exactly one reaction;
  the only exception, ORE, is the raw material input to the entire process and is not produced by a reaction.

  You just need to know how much ORE you'll need to collect before you can produce one unit of FUEL.

  Each reaction gives specific quantities for its inputs and output;
  reactions cannot be partially run, so only whole integer multiples of these quantities can be used.
  (It's okay to have leftover chemicals when you're done, though.)
  For example, the reaction 1 A, 2 B, 3 C => 2 D means that exactly 2 units of chemical D can be produced by consuming exactly 1 A, 2 B and 3 C.
  You can run the full reaction as many times as necessary; for example, you could produce 10 D by consuming 5 A, 10 B, and 15 C.

  Suppose your nanofactory produces the following list of reactions:

  10 ORE => 10 A
  1 ORE => 1 B
  7 A, 1 B => 1 C
  7 A, 1 C => 1 D
  7 A, 1 D => 1 E
  7 A, 1 E => 1 FUEL

  The first two reactions use only ORE as inputs;
  they indicate that you can produce as much of chemical A as you want
  (in increments of 10 units, each 10 costing 10 ORE) and as much of chemical B as you want (each costing 1 ORE).
  To produce 1 FUEL, a total of 31 ORE is required:
  1 ORE to produce 1 B, then 30 more ORE to produce the 7 + 7 + 7 + 7 = 28 A (with 2 extra A wasted) required in the reactions to convert the
  B into C, C into D, D into E, and finally E into FUEL.
  (30 A is produced because its reaction requires that it is created in increments of 10.)

  Or, suppose you have the following list of reactions:

  9 ORE => 2 A
  8 ORE => 3 B
  7 ORE => 5 C
  3 A, 4 B => 1 AB
  5 B, 7 C => 1 BC
  4 C, 1 A => 1 CA
  2 AB, 3 BC, 4 CA => 1 FUEL

  The above list of reactions requires 165 ORE to produce 1 FUEL:

      Consume 45 ORE to produce 10 A.
      Consume 64 ORE to produce 24 B.
      Consume 56 ORE to produce 40 C.
      Consume 6 A, 8 B to produce 2 AB.
      Consume 15 B, 21 C to produce 3 BC.
      Consume 16 C, 4 A to produce 4 CA.
      Consume 2 AB, 3 BC, 4 CA to produce 1 FUEL.

  Here are some larger examples:

      13312 ORE for 1 FUEL:

      157 ORE => 5 NZVS
      165 ORE => 6 DCFZ
      44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
      12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
      179 ORE => 7 PSHF
      177 ORE => 5 HKGWZ
      7 DCFZ, 7 PSHF => 2 XJWVT
      165 ORE => 2 GPVTF
      3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT

      180697 ORE for 1 FUEL:

      2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
      17 NVRVD, 3 JNWZP => 8 VPVL
      53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
      22 VJHF, 37 MNCFX => 5 FWMGM
      139 ORE => 4 NVRVD
      144 ORE => 7 JNWZP
      5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
      5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
      145 ORE => 6 MNCFX
      1 NVRVD => 8 CXFTF
      1 VJHF, 6 MNCFX => 4 RFSQX
      176 ORE => 6 VJHF

      2210736 ORE for 1 FUEL:

      171 ORE => 8 CNZTR
      7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
      114 ORE => 4 BHXH
      14 VRPVC => 6 BMBT
      6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
      6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
      15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
      13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
      5 BMBT => 4 WPTQ
      189 ORE => 9 KTJDG
      1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
      12 VRPVC, 27 CNZTR => 2 XDBXC
      15 KTJDG, 12 BHXH => 5 XCVML
      3 BHXH, 2 VRPVC => 7 MZWV
      121 ORE => 7 VRPVC
      7 XCVML => 6 RJRHP
      5 BHXH, 4 VRPVC => 5 LTCX

    Given the list of reactions in your puzzle input, what is the minimum amount of ORE required to produce exactly 1 FUEL?
  """
  def parse(reactions) do
    reactions
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_reaction/1)
    |> Enum.map(fn {{output, qty}, inputs} -> {output, {qty, inputs}} end)
    |> Enum.into(%{})
  end

  defmodule Chemicals do
    defstruct [:chemicals]

    def new(chemicals) when is_list(chemicals) do
      new(Enum.into(chemicals, %{}))
    end

    def new(chemicals) when is_map(chemicals) do
      %__MODULE__{chemicals: chemicals}
    end

    def remove(chem, chemical, quantity) do
      have = Map.fetch!(chem.chemicals, chemical)

      if have <= quantity do
        %{chem | chemicals: Map.delete(chem.chemicals, chemical)}
      else
        left = have - quantity

        %{chem | chemicals: Map.put(chem.chemicals, chemical, left)}
      end
    end

    def add(chem1, chem2) do
      Map.merge(
        chem1.chemicals,
        chem2.chemicals,
        fn _key, q1, q2 ->
          q1 + q2
        end
      )
      |> new()
    end

    def multiply(chem, multiple) do
      chem.chemicals
      |> Enum.map(fn {chemical, quantity} ->
        {chemical, quantity * multiple}
      end)
      |> new()
    end
  end

  def ore_for_fuel(fuel_quantity, reactions) do
    scaled = minimum_inputs_for("FUEL", fuel_quantity, reactions)

    reduce(scaled, reactions)
  end

  def minimum_inputs_for(chemical, quantity, reactions) do
    {qty, inputs} = Map.fetch!(reactions, chemical)
    multiplier = lowest_multiplier(quantity, qty, qty)

    Chemicals.multiply(inputs, multiplier)
  end

  def depth_to_ore(reactions) do
    direct_to_ore =
      Map.keys(reactions)
      |> Enum.filter(fn chemical ->
        {_, inputs} = Map.fetch!(reactions, chemical)

        Enum.all?(Map.keys(inputs.chemicals), &(&1 == "ORE"))
      end)

    ore_depth = Enum.map(direct_to_ore, fn ch -> {ch, 1} end) |> Enum.into(%{})

    rest =
      Enum.reduce(direct_to_ore, reactions, fn ch, acc ->
        Map.delete(acc, ch)
      end)

    do_depth_to_ore(rest, ore_depth)
  end

  defp do_depth_to_ore(reactions, depths) when map_size(reactions) == 0, do: depths

  defp do_depth_to_ore(reactions, depths) do
    reductions =
      Enum.filter(reactions, fn {_, {_, inputs}} ->
        Enum.all?(inputs.chemicals, fn {chem, _} ->
          Map.has_key?(depths, chem)
        end)
      end)

    if length(reductions) == 0 do
      raise "No reductions possible?"
    else
      new_depths =
        Enum.reduce(reductions, depths, fn {chemical, {_, inputs}}, acc ->
          input_depth =
            inputs.chemicals
            |> Enum.map(fn {chemical, _} -> Map.fetch!(depths, chemical) end)
            |> Enum.max()

          Map.put(acc, chemical, input_depth + 1)
        end)

      new_reactions =
        Enum.reduce(reductions, reactions, fn {chemical, _}, acc ->
          Map.delete(acc, chemical)
        end)

      do_depth_to_ore(new_reactions, new_depths)
    end
  end

  # TODO update this to use depth to order chemical reductions
  defp reduce(chemicals, reactions) do
    if only_ore?(chemicals) do
      Map.fetch!(chemicals.chemicals, "ORE")
    else
      do_reduce(chemicals, reactions)
    end
  end

  defp do_reduce(chemicals, reactions) do
    {_type, chemical, ratio} = next_reduction(chemicals, reactions)
    {quantity, inputs} = Map.fetch!(reactions, chemical)
    need = quantity * ratio
    scaled = Chemicals.multiply(inputs, ratio)

    new_chemicals =
      chemicals
      |> Chemicals.remove(chemical, need)
      |> Chemicals.add(scaled)

    reduce(new_chemicals, reactions)
  end

  defp next_reduction(chemicals, reactions) do
    depths = depth_to_ore(reactions)
    max = depths |> Map.values() |> Enum.max()

    Map.keys(chemicals.chemicals)
    |> Enum.reject(&(&1 == "ORE"))
    |> Enum.map(fn chemical ->
      have = Map.fetch!(chemicals.chemicals, chemical)
      {qty, _} = Map.fetch!(reactions, chemical)

      cond do
        have >= qty ->
          ratio = div(have, qty)

          {:whole_ratio, chemical, ratio}

        true ->
          {:consume_leftover, chemical, 1}
      end
    end)
    |> Enum.sort_by(
      fn
        {:whole_ratio, _, _} ->
          max + 1

        {:consume_leftover, chemical, _} ->
          Map.fetch!(depths, chemical)
      end,
      :desc
    )
    |> hd
  end

  defp only_ore?(chem) do
    Map.has_key?(chem.chemicals, "ORE") and map_size(chem.chemicals) == 1
  end

  def lowest_multiplier(required, have, increment)

  def lowest_multiplier(required, have, _) when required <= have, do: 1

  def lowest_multiplier(required, have, increment) do
    1 + lowest_multiplier(required, have + increment, increment)
  end

  defp parse_reaction(reaction) do
    [input, output] = String.split(reaction, " => ", trim: true, parts: 2)

    inputs =
      input
      |> String.split(", ", trim: true)
      |> Enum.map(&parse_chemical/1)
      |> Chemicals.new()

    chemical = parse_chemical(output)

    {chemical, inputs}
  end

  defp parse_chemical(chemical) do
    [quantity, element] = String.split(chemical, " ")

    {element, String.to_integer(quantity)}
  end
end
