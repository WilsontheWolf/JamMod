local jd_def = JokerDisplay.Definitions

jd_def["j_jam_special_snowflake"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "exp" }
            }
        }
    },
}


return {
    key = 'j_jam_special_snowflake',
    config = {
        extra = {
            mod = 0.2,
            mult = 1
        }
    },
    loc_txt = {
        name = "Special Snowflake",
        text = {
          "This Joker gains {X:mult,C:white} X#1# {} Mult",
          "for each {C:attention}Uniquely enhanced card",
          "in your full deck",
          "{C:inactive}(ex: {C:green}gold, gold with red seal, steel, etc.{}{C:inactive})",
          "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        },
    },
    atlas = 'Jokers',
    pos = {
        x = 6,
        y = 3
    },
    soul_pos = {
      x = 7,
      y = 3
    },
    rarity = 2,
    cost = 6,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.mult > 1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
                Xmult_mod = card.ability.extra.Xmult
            }
        end
    end,
    loc_vars = function(self, info_queue, center)
        return {
            vars = {center.ability.extra.mod, center.ability.extra.mult}
        }
    end,
    update = function(self, card, dt)
        if G.STAGE ~= G.STAGES.RUN then return end
        local seen = {}
        local count = 0
        for k, v in pairs(G.playing_cards) do
            local str = v.config.center.key .. "," .. (v.seal or "") .. "," .. (v.edition and v.edition.key or "")
            if str ~= "c_base,," and not seen[str] then
                seen[str] = true
                count = count + 1
            end
        end
        card.ability.extra.mult = 1 + math.max(0, count) * card.ability.extra.mod
    end, 
    blueprint_compat = true
}
