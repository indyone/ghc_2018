defmodule Simulator do
  def start() do
    %{
      rides: [
        %{id: 1, start: {0, 0}, end: {1, 3}, earliest: 2, latest: 9, distance: 4},
        %{id: 2, start: {1, 2}, end: {3, 4}, earliest: 9, latest: 19, distance: 4}
      ],
      vehicles: 1,
      bonus: 4,
      time: 20
    }
    |> Simulator.start()
  end

  def start(%{rides: rides, vehicles: num_vechicles, bonus: bonus, time: max_time}) do
    state = %{
      rides: rides,
      vehicles:
        Enum.map(1..(num_vechicles), fn id ->
          %{id: id, pos: {0, 0}, ride: nil, finished: []}
        end),
      bonus: bonus,
      max_time: max_time
    }

    %{vehicles: vecs} = Enum.reduce(0..(max_time - 1), state, fn t, s -> do_sim(s, t) end)

    Enum.map(vecs, fn v -> {v.id, v.finished} end)
  end

  def do_sim(state, t) do
    state
    |> assign_rides(t)
    |> release_rides(t)
  end

  def release_rides(state, t) do
    Enum.reduce(state.vehicles, state, fn
      %{ride: nil}, state ->
        state

      vec, state ->
        if vec.ride.release == t do
          n_vec = %{vec | ride: nil, finished: [vec.ride.id | vec.finished], pos: vec.ride.end}

          n_vecs =
            Enum.map(state.vehicles, fn p_vec ->
              if n_vec.id == p_vec.id, do: n_vec, else: p_vec
            end)

          %{state | vehicles: n_vecs}
        else
          state
        end
    end)
  end

  def assign_rides(state, t) do
    Enum.reduce(state.vehicles, state, fn
      %{ride: nil} = vec, state ->
        case best_ride(vec.pos, state.rides, t) do
          nil ->
            state

          ride ->
            n_rides = Enum.filter(state.rides, fn r1 -> r1.id != ride.id end)
            n_vec = %{vec | ride: ride}

            n_vecs =
              Enum.map(state.vehicles, fn p_vec ->
                if n_vec.id == p_vec.id, do: n_vec, else: p_vec
              end)

            %{state | rides: n_rides, vehicles: n_vecs}
        end

      _, state ->
        state
    end)
  end

  def best_ride(vec_pos, rides, t) do
    Enum.reduce_while(rides, nil, fn r, _ ->
      pi = distance(vec_pos, r.start)
      est = r.latest - t - pi - r.distance

      if est > 0 do
        {:halt, Map.put(r, :release, max(t + pi, r.earliest) + r.distance)}
      else
        {:cont, nil}
      end
    end)
  end

  def distance({from_x, from_y}, {to_x, to_y}) do
    abs(from_x - to_x) + abs(from_y - to_y)
  end
end
