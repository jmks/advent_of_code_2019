defmodule Day09 do
  @moduledoc """
--- Day 9: Sensor Boost ---

You've just said goodbye to the rebooted rover and left Mars when you receive a faint distress signal coming from the asteroid belt. It must be the Ceres monitoring station!

In order to lock on to the signal, you'll need to boost your sensors. The Elves send up the latest BOOST program - Basic Operation Of System Test.

While BOOST (your puzzle input) is capable of boosting your sensors, for tenuous safety reasons, it refuses to do so until the computer it runs on passes some checks to demonstrate it is a complete Intcode computer.

Your existing Intcode computer is missing one key feature: it needs support for parameters in relative mode.

Parameters in mode 2, relative mode, behave very similarly to parameters in position mode: the parameter is interpreted as a position. Like position mode, parameters in relative mode can be read from or written to.

The important difference is that relative mode parameters don't count from address 0. Instead, they count from a value called the relative base. The relative base starts at 0.

The address a relative mode parameter refers to is itself plus the current relative base. When the relative base is 0, relative mode parameters and position mode parameters with the same value refer to the same address.

For example, given a relative base of 50, a relative mode parameter of -7 refers to memory address 50 + -7 = 43.

The relative base is modified with the relative base offset instruction:

Opcode 9 adjusts the relative base by the value of its only parameter. The relative base increases (or decreases, if the value is negative) by the value of the parameter.
For example, if the relative base is 2000, then after the instruction 109,19, the relative base would be 2019. If the next instruction were 204,-34, then the value at address 1985 would be output.

Your Intcode computer will also need a few other capabilities:

The computer's available memory should be much larger than the initial program. Memory beyond the initial program starts with the value 0 and can be read or written like any other memory. (It is invalid to try to access memory at a negative address, though.)
The computer should have support for large numbers. Some instructions near the beginning of the BOOST program will verify this capability.
Here are some example programs that use these features:

109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99 takes no input and produces a copy of itself as output.
1102,34915192,34915192,7,4,7,99,0 should output a 16-digit number.
104,1125899906842624,99 should output the large number in the middle.
The BOOST program will ask for a single input; run it in test mode by providing it the value 1. It will perform a series of checks on each opcode, output any opcodes (and the associated parameter modes) that seem to be functioning incorrectly, and finally output a BOOST keycode.

Once your Intcode computer is fully functional, the BOOST program should report no malfunctioning opcodes when run in test mode; it should only output a single value, the BOOST keycode. What BOOST keycode does it produce?

"""
defmodule IntcodeState do
    defstruct state: :running, code: [], instruction_pointer: 0, inputs: [], outputs: []

    def diagnostic_code(state), do: hd(state.outputs)

    def next_opcode_and_modes(state) do
      opcode_mask = next_instruction(state)
      digits = Integer.digits(opcode_mask) |> Enum.reverse

      opcode = digits |> Enum.take(2) |> Enum.reverse |> normalize_opcode
      modes = digits |> Enum.drop(2) |> normalize_modes |> Enum.map(&translate_mode/1)

      {opcode, modes}
    end

    def next_args(state, number) when is_integer(number) do
      Enum.drop(state.code, state.instruction_pointer + 1) |> Enum.take(number)
    end

    defp next_instruction(state) do
      Enum.drop(state.code, state.instruction_pointer) |> hd
    end

    defp normalize_opcode([o]), do: normalize_opcode([0, o])
    defp normalize_opcode([0, 1]), do: :add
    defp normalize_opcode([0, 2]), do: :multiply
    defp normalize_opcode([0, 3]), do: :save_input
    defp normalize_opcode([0, 4]), do: :write_output
    defp normalize_opcode([0, 5]), do: :jump_if_true
    defp normalize_opcode([0, 6]), do: :jump_if_false
    defp normalize_opcode([0, 7]), do: :less_than
    defp normalize_opcode([0, 8]), do: :equal
    defp normalize_opcode([9, 9]), do: :abort

    defp normalize_modes([]), do: {0, 0, 0}
    defp normalize_modes([m]), do: {m, 0, 0}
    defp normalize_modes([m, n]), do: {m, n, 0}
    defp normalize_modes([m, n, o]), do: {m, n, o}

    defp translate_mode(0), do: :position_mode
    defp translate_mode(1), do: :parameter_mode
    defp translate_mode(2), do: :relative_mode
  end

  @max_opcode_args 3

  def intcode(code, inputs), do: do_intcode(%IntcodeState{code: code, inputs: inputs})

  defp do_intcode(state = %IntcodeState{state: :running}) do
    new_state = process(state)

    case new_state.state do
      :halted ->
        {:halted, IntcodeState.diagnostic_code(new_state)}
      :wrote_output ->
        {:wrote_output, IntcodeState.diagnostic_code(new_state), new_state}
      :running ->
        do_intcode(new_state)
    end
  end

  defp process(state) do
    {opcode, modes} = IntcodeState.next_opcode_and_modes(state)
    args = IntcodeState.next_args(state, @max_opcode_args)

    {ip_update, new_code, new_inputs, new_outputs} = eval(
      opcode,
      modes,
      args,
      state.inputs,
      state.outputs, # TODO: this probably isn't necessary
      state.code
    )

    new_instruction_pointer = update_instruction_pointer(ip_update, state.instruction_pointer + 1)
    new_state =
      case opcode do
        :write_output -> :wrote_output
        :abort -> :halted
        _ -> :running
      end

    %IntcodeState{
      state: new_state,
      code: new_code,
      instruction_pointer: new_instruction_pointer,
      inputs: new_inputs,
      outputs: new_outputs
    }
  end

  defp update_instruction_pointer({:inc, value}, ip), do: value + ip
  defp update_instruction_pointer({:set, value}, _ip), do: value

  defp eval(opcode, modes, args, inputs, outputs, codes)

  defp eval(:add, {mode1, mode2, _}, [arg1, arg2, arg3 | _], inputs, outputs, codes) do
    new_value = value_of(codes, mode1, arg1) + value_of(codes, mode2, arg2)
    new_codes = List.replace_at(codes, arg3, new_value)

    {{:inc, 3}, new_codes, inputs, outputs}
  end

  defp eval(:multiply, {mode1, mode2, _}, [arg1, arg2, arg3 | _], inputs, outputs, codes) do
    new_value = value_of(codes, mode1, arg1) * value_of(codes, mode2, arg2)
    new_codes = List.replace_at(codes, arg3, new_value)

    {{:inc, 3}, new_codes, inputs, outputs}
  end

  defp eval(:save_input, _modes, [index | _], [input | new_inputs], outputs, codes) do
    new_codes = List.replace_at(codes, index, input)

    {{:inc, 1}, new_codes, new_inputs, outputs}
  end

  defp eval(:write_output, {mode, _, _}, [index | _], inputs, outputs, codes) do
    value = value_of(codes, mode, index)

    {{:inc, 1}, codes, inputs, [value | outputs]}
  end

  defp eval(:jump_if_true, {mode1, mode2, _}, [arg1, arg2 | _], inputs, outputs, codes) do
    if value_of(codes, mode1, arg1) == 0 do
      # no-op
      {{:inc, 2}, codes, inputs, outputs}
    else
      new_ip = value_of(codes, mode2, arg2)

      {{:set, new_ip}, codes, inputs, outputs}
    end
  end

  defp eval(:jump_if_false, {mode1, mode2, _}, [arg1, arg2 | _], inputs, outputs, codes) do
    if value_of(codes, mode1, arg1) == 0 do
      new_ip = value_of(codes, mode2, arg2)

      {{:set, new_ip}, codes, inputs, outputs}
    else
      # no-op
      {{:inc, 2}, codes, inputs, outputs}
    end
  end

  defp eval(:less_than, {mode1, mode2, _}, [arg1, arg2, arg3| _], inputs, outputs, codes) do
    new_value = if value_of(codes, mode1, arg1) < value_of(codes, mode2, arg2), do: 1, else: 0
    new_codes = List.replace_at(codes, arg3, new_value)

    {{:inc, 3}, new_codes, inputs, outputs}
  end

  defp eval(:equal, {mode1, mode2, _}, [arg1, arg2, arg3| _], inputs, outputs, codes) do
    new_value = if value_of(codes, mode1, arg1) == value_of(codes, mode2, arg2), do: 1, else: 0
    new_codes = List.replace_at(codes, arg3, new_value)

    {{:inc, 3}, new_codes, inputs, outputs}
  end

  defp eval(:abort, _modes, _args, inputs, outputs, codes) do
    {{:inc, length(codes)}, codes, inputs, outputs}
  end

  defp value_of(codes, :position_mode, index), do: Enum.at(codes, index)
  defp value_of(_codes, :parameter_mode, value), do: value
end
