defmodule Parser do


def read(name)  do
    {:ok, file } = File.open(name, [:read])
    readline(file, %{})
end

defp readline(_file, {:ok, acc}), do: acc
defp readline(file, %{} = acc) do
    acc = 
    IO.read(file, :line)
    |> process(acc)
    readline(file, acc)
end
defp readline(file, {acc, rides}) do
    {acc, rides} = 
    IO.read(file, :line)
    |> process(acc, rides)
    readline(file, {acc, rides})
end

def process(:eof, acc, _rides), do: {:ok, acc}
def process(line, %{}) do
    [row, col, vehicles, rides, bonus, time] =
    line 
    |> String.split()
    acc = 
    %{rides: [],
    size: {String.to_integer(row), String.to_integer(col)},
    vehicles: String.to_integer(vehicles),
    bonus: String.to_integer(bonus),
    time: String.to_integer(time)}
    {acc, String.to_integer(rides) - 1}
end
def process(line, acc, rides) do
    [x_s, y_s, x_l, y_l, earliest, latest] = line |> String.split() 
    IO.inspect(rides)
    list = acc[:rides]
    new = %{
        id: rides,
        start: {String.to_integer(x_s), String.to_integer(y_s)},
        end: {String.to_integer(x_l), String.to_integer(y_l)},
        earliest: String.to_integer(earliest),
        latest: String.to_integer(latest),
        distance: distance({String.to_integer(x_s), String.to_integer(y_s)}, {String.to_integer(x_l), String.to_integer(y_l)})}
    {Map.put(acc, :rides, [new | list]), rides - 1}
end

def distance({from_x, from_y}, {to_x, to_y}) do
    abs(from_x - to_x) + abs(from_y - to_y)
end

end