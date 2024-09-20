--- STEAMODDED HEADER
--- MOD_NAME: JamMod
--- MOD_ID: JamMod
--- MOD_AUTHOR: []
--- MOD_DESCRIPTION: JellyMod for modern SMODS
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0919a]
--- PREFIX: jammod
if JokerDisplay then
    assert(SMODS.load_file("joker_display_definitions.lua"))()
end


SMODS.Atlas {
  key = "Jokers",
  path = "Jokers.png",
  px = 71,
  py = 95
}


SMODS.Joker {
  key = 'double_vision',
  loc_txt = {
    name = 'Double Vision',
    text = {
      "All cards are",
      "considered",
      "{C:attention}2s{}",
    }
  },
  atlas = 'Jokers',
  pos = { x = 0, y = 0 },
  rarity = 3,
  cost = 10,
  blueprint_compat = false
}

SMODS.Joker {
    key = 'prosopagnosia',
    loc_txt = {
        name = 'Prosopagnosia',
        text = {
          "{C:red}NO{} cards are",
          "considered",
          "{C:attention}face{} cards",
        }
    },
    atlas = 'Jokers',
    pos = {
      x = 0,
      y = 0
    },
    rarity = 1,
    cost = 5,
    blueprint_compat = false
}

SMODS.Joker {
    key = 'pessimist',
    config = {extra = 2},
    loc_txt = {
        name = 'Pessimist',
        text = {
          "Sell this card to apply",
          "{C:dark_edition}negative{} to a random Joker.",
          "Permanent {C:blue}-#1#{} hands.",
          "{C:inactive}({C:attention}Destroys{C:inactive} itself when blind selected){}"
        }
    },
    atlas = 'Jokers',
    pos = {
        x = 0,
        y = 0
    },
    rarity = 3,
    cost = 10,
    calculate = function(self, card, context)
      if context.selling_self then
        local eligible = {}
        for k, v in pairs(G.jokers.cards) do
            if v.ability.set == 'Joker' and (not v.edition) and v ~= card and v ~= context.blueprint_card then
                table.insert(eligible, v)
            end
        end
        if #eligible == 0 then
          return nil, true
        end
        local eligible_card = pseudorandom_element(eligible, pseudoseed("jammod_pessimist"))
        eligible_card:set_edition({negative = true}, true)
        G.hand:change_size(-card.ability.extra)
        return nil, true
      elseif context.setting_blind and not self.getting_sliced and not context.blueprint then
        G.E_MANAGER:add_event(
          Event({
            func = function()
              card:start_dissolve()
              return true 
            end 
          })
        )
      end
    end,
    loc_vars = function(self, info_queue, center)
      info_queue[#info_queue + 1] = {
        key = 'e_negative_consumable', 
        set = 'Edition',
        config = {extra = 1}
      }
      return { vars = { center.ability.extra } }
    end,
    blueprint_compat = true
}
