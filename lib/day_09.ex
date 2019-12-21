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

--- Part Two ---

You now have a complete Intcode computer.

Finally, you can lock on to the Ceres distress signal! You just need to boost your sensors using the BOOST program.

The program runs in sensor boost mode by providing the input instruction the value 2. Once run, it will boost the sensors automatically, but it might take a few seconds to complete the operation on slower hardware. In sensor boost mode, the program will output a single value: the coordinates of the distress signal.

Run the BOOST program in sensor boost mode. What are the coordinates of the distress signal?
"""
defmodule IntcodeState do
    defstruct state: :running, code: %{}, instruction_pointer: 0, inputs: [], outputs: [], relative_base: 0

    def new(code, inputs) when is_list(code) and is_list(inputs) do
      memory = code
      |> Enum.with_index
      |> Enum.reduce(%{}, fn {instruction, index}, mem ->
        Map.put_new(mem, index, instruction)
      end)

      %__MODULE__{
        code: memory,
        inputs: inputs
      }
    end

    def diagnostic_code(state) do
      cond do
        Enum.any?(state.outputs) ->
          hd(state.outputs)

        Enum.any?(state.inputs) ->
          hd(state.inputs)

        true ->
          raise "No diagnostic code could be found"
      end
    end

    def next_opcode_and_modes(state) do
      opcode_mask = next_instruction(state)
      digits = Integer.digits(opcode_mask) |> Enum.reverse

      opcode = digits |> Enum.take(2) |> Enum.reverse |> normalize_opcode
      modes = digits |> Enum.drop(2) |> normalize_modes

      {opcode, modes}
    end

    def next_args(state, number) when is_integer(number) do
      arg_location = state.instruction_pointer+1
      memory_locations = arg_location..(arg_location+number)

      Enum.map(memory_locations, fn loc ->
        Map.get(state.code, loc)
      end)
    end

    def value_of(state, location, mode)

    def value_of(state, location, :position_mode), do: Map.get(state.code, location, 0)
    def value_of(_state, value, :immediate_mode), do: value
    def value_of(state, location, :relative_mode), do: Map.get(state.code, state.relative_base + location, 0)

    def write_address(state, value, mode)
    def write_address(state, value, :relative_mode), do: state.relative_base + value
    def write_address(_state, value, _), do: value

    def update_code_at(state, location, value) do
      Map.update(state.code, location, value, fn _old_value -> value end)
    end

    defp next_instruction(state) do
      Map.get(state.code, state.instruction_pointer)
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
    defp normalize_opcode([0, 9]), do: :relative_base_offset
    defp normalize_opcode([9, 9]), do: :abort

    defp normalize_modes([]), do: {:position_mode, :position_mode, :position_mode}
    defp normalize_modes([m]), do: {translate_mode(m), :position_mode, :position_mode}
    defp normalize_modes([m, n]), do: {translate_mode(m), translate_mode(n), :position_mode}
    defp normalize_modes([m, n, o]), do: {translate_mode(m), translate_mode(n), translate_mode(o)}

    defp translate_mode(0), do: :position_mode
    defp translate_mode(1), do: :immediate_mode
    defp translate_mode(2), do: :relative_mode
  end

  @max_opcode_args 3

  def intcode_stepwise(code, inputs), do: do_intcode(IntcodeState.new(code, inputs))

  def intcode_halt(code, inputs), do: run_until_halted(IntcodeState.new(code, inputs))

  def intcode_output_after_halt(code, inputs) do
    output_after_halt(IntcodeState.new(code, inputs), [])
  end

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

  defp run_until_halted(state) do
    case do_intcode(state) do
      {:halted, diagnostic_code} ->
        diagnostic_code
      {:wrote_output, _, output_state} ->
        new_state = %{output_state | state: :running}
        run_until_halted(new_state)
    end
  end

  defp output_after_halt(state, output_acc) do
    # IO.inspect state
    case do_intcode(state) do
      {:halted, _} ->
        Enum.reverse(output_acc)
      {:wrote_output, output, output_state} ->
        new_state = %{output_state | state: :running}
        new_output = [output | output_acc]

        output_after_halt(new_state, new_output)
    end
  end

  defp process(state) do
    {opcode, modes} = IntcodeState.next_opcode_and_modes(state)
    args = IntcodeState.next_args(state, @max_opcode_args)

    eval(
      opcode,
      modes,
      args,
      %{state | instruction_pointer: state.instruction_pointer + 1}
    )
  end

  defp eval(opcode, modes, args, state)

  defp eval(:add, {mode1, mode2, mode3}, [arg1, arg2, arg3 | _], state) do
    new_value = IntcodeState.value_of(state, arg1, mode1) + IntcodeState.value_of(state, arg2, mode2)
    address = IntcodeState.write_address(state, arg3, mode3)
    new_code = IntcodeState.update_code_at(state, address, new_value)

    %{state |
      code: new_code,
      instruction_pointer: state.instruction_pointer + 3
    }
  end

  defp eval(:multiply, {mode1, mode2, mode3}, [arg1, arg2, arg3 | _], state) do
    new_value = IntcodeState.value_of(state, arg1, mode1) * IntcodeState.value_of(state, arg2, mode2)
    address = IntcodeState.write_address(state, arg3, mode3)
    new_code = IntcodeState.update_code_at(state, address, new_value)


    %{state |
      code: new_code,
      instruction_pointer: state.instruction_pointer + 3
    }
  end

  defp eval(:save_input, {mode, _, _}, [arg | _], state = %IntcodeState{inputs: [input | new_inputs]}) do
    address = IntcodeState.write_address(state, arg, mode)
    new_code = IntcodeState.update_code_at(state, address, input)

    %{state |
      code: new_code,
      instruction_pointer: state.instruction_pointer + 1,
      inputs: new_inputs
    }
  end

  defp eval(:write_output, {mode, _, _}, [index | _], state) do
    value = IntcodeState.value_of(state, index, mode)

    %{state |
       state: :wrote_output,
       instruction_pointer: state.instruction_pointer + 1,
       outputs: [value | state.outputs]
    }
  end

  defp eval(:jump_if_true, {mode1, mode2, _}, [arg1, arg2 | _], state) do
    if IntcodeState.value_of(state, arg1, mode1) == 0 do
      # no-op
      %{state | instruction_pointer: state.instruction_pointer + 2}
    else
      new_ip = IntcodeState.value_of(state, arg2, mode2)

      %{state | instruction_pointer: new_ip}
    end
  end

  defp eval(:jump_if_false, {mode1, mode2, _}, [arg1, arg2 | _], state) do
    if IntcodeState.value_of(state, arg1, mode1) == 0 do
      new_ip = IntcodeState.value_of(state, arg2, mode2)

      %{state | instruction_pointer: new_ip}
    else
      # no-op
      %{state | instruction_pointer: state.instruction_pointer + 2}
    end
  end

  defp eval(:less_than, {mode1, mode2, mode3}, [arg1, arg2, arg3| _], state) do
    new_value = if IntcodeState.value_of(state, arg1, mode1) < IntcodeState.value_of(state, arg2, mode2), do: 1, else: 0
    address = IntcodeState.write_address(state, arg3, mode3)
    new_code = IntcodeState.update_code_at(state, address, new_value)

    %{state |
      instruction_pointer: state.instruction_pointer + 3,
      code: new_code
    }
  end

  defp eval(:equal, {mode1, mode2, mode3}, [arg1, arg2, arg3| _], state) do
    new_value = if IntcodeState.value_of(state, arg1, mode1) == IntcodeState.value_of(state, arg2, mode2), do: 1, else: 0
    address = IntcodeState.write_address(state, arg3, mode3)
    new_code = IntcodeState.update_code_at(state, address, new_value)

    %{state |
      instruction_pointer: state.instruction_pointer + 3,
      code: new_code
    }
  end

  defp eval(:relative_base_offset, {mode1, _, _}, [arg1 | _], state) do
    new_relative_base = state.relative_base + IntcodeState.value_of(state, arg1, mode1)

    %{state |
      instruction_pointer: state.instruction_pointer + 1,
      relative_base: new_relative_base
    }
  end

  defp eval(:abort, _modes, _args, state) do
    # TODO: maybe move inputs to outputs here?
    %{state | state: :halted}
  end
end
