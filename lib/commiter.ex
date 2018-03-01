defmodule Commiter do
   def commit(list) do
       {:ok, file} = File.open "hello", [:write]
   
       Enum.each(list, fn {id, rides} -> 
        IO.write(file, id)
        IO.write(file, " ")
        Enum.each(rides, fn ride ->
            IO.write(file, ride)
            IO.write(file, " ") 
        end)
        IO.write(file, "\n")
    end )
   end 
end