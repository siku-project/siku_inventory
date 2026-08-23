if InventoryConfig.dropLifetime > 0 then
  Siku.timers.setInterval(InventoryConfig.dropSweepInterval, function()
    local removed <const> = SweepExpiredDrops()

    if removed > 0 then
      Siku.print.debug(('Swept %d expired drop(s)'):format(removed))
    end
  end)
end
