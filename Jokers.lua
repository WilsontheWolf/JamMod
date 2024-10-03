--- STEAMODDED HEADER
--- MOD_NAME: JamMod
--- MOD_ID: JamMod
--- MOD_AUTHOR: [WilsontheWolf]
--- MOD_DESCRIPTION: JellyMod for modern SMODS
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0919a]
--- PREFIX: jam
--- BADGE_COLOUR: 7F0000
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
  pos = { x = 8, y = 2 },
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
      x = 7,
      y = 2
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
      x = 6,
      y = 2
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
        local eligible_card = pseudorandom_element(eligible, pseudoseed("jam_pessimist"))
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
    blueprint_compat = true,
    eternal_compat = false
}

SMODS.Joker {
    key = 'one_more_time',
    config = {
        extra = 0
    },
    loc_txt = {
        name = "One More Time!",
        text = {
          "Sell this card to",
          "Add your previous hand to current score",
          "(Currently {C:attention,E:1,S:1}#1#{})",
        },    
    },
    atlas = 'Jokers',
    pos = {
      x = 1,
      y = 3
    },
    rarity = 1,
    cost = 8,
    calculate = function(self, card, context)
      if context.selling_self and G.STATE == G.STATES.SELECTING_HAND then
        G.E_MANAGER:add_event(Event({
            func = function()
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                  message = "+" .. number_format(G.GAME.round_resets.jam_last_chips or 0)
                });
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
          blocking = true,
          trigger = 'ease',
          ref_table = G.GAME,
          ref_value = 'chips',
          ease_to = G.GAME.chips + math.floor(G.GAME.round_resets.jam_last_chips or 0),
          delay = 0.2,
          func = (function(t) return math.floor(t) end)
        }))

        G.E_MANAGER:add_event(Event({
          func = (function(t) if G.GAME.chips >  G.GAME.blind.chips then G.STATE = G.STATES.NEW_ROUND 
          G.STATE_COMPLETE = false
          end
          return true end)
        }))
        
        return nil, true
      end
    end,
    loc_vars = function(self, info_queue, card)
      return { vars = { G.GAME.round_resets.jam_last_chips or 0 } }
    end,
    blueprint_compat = true,
    eternal_compat = false,
}

SMODS.Joker {
    key = 'tarlton',
    config = {
        extra = 0
    },
    loc_txt = {
        name = "Tarlton",
        text = {
          "Copies the effects of",
          "all other {C:attention}Jokers{}",
          "In your possession.",
          "{C:inactive}(must be compatible){}"
        },
    },
    atlas = 'Jokers',
    pos = {
      x = 1,
      y = 2
    },
    soul_pos = {
      x = 9,
      y = 3
    },
    rarity = 4,
    cost = 20,
    calculate = function(self, card, context)
      if not context.blueprint then
        local other_joker = nil
        local final_ret = nil
        for i=1,#G.jokers.cards do
            other_joker = G.jokers.cards[i]
            if other_joker and other_joker.ability.name ~= card.ability.name and other_joker.config.center.blueprint_compat then
                context.blueprint_card = card
                context.blueprint = 1
                local other_joker_ret = other_joker:calculate_joker(context)
            end
        end
        if final_ret then
            return final_ret
        end
      end
    end,
    blueprint_compat = false
}

SMODS.Joker {
    key = 'greedy_pot',
    loc_txt = {
        name = 'Greedy Pot',
        text = {
          "After play or discard, always draw", 
          "{C:attention}#1# more{} cards than you would otherwise.",
        }
    },
    config = {extra = 2},
    atlas = 'Jokers',
    pos = {
        x = 6,
        y = 1
    },
    rarity = 3,
    cost = 10,
    loc_vars = function(self, info_queue, center)
      return { vars = { center.ability.extra } }
    end,
    blueprint_compat = false
}

SMODS.Joker {
    key = 'all_ones',
    loc_txt = {
        name = 'Oops! All 1s',
        text = {
            "Halves all {C:attention}listed",
            "{C:green,E:1,S:1.1}probabilities",
            "{C:inactive}(ex: {C:green}1 in 3{C:inactive} -> {C:green}0.5 in 3{C:inactive})",
        }
    },
    config = {extra = 2},
    atlas = 'Jokers',
    pos = {
        x = 3,
        y = 2
    },
    rarity = 3,
    cost = 10,
    add_to_deck = function (self, card, from_debuff)
      for k, v in pairs(G.GAME.probabilities) do
        G.GAME.probabilities[k] = v / 2
      end
    end,
    remove_from_deck = function (self, card, from_debuff)
      for k, v in pairs(G.GAME.probabilities) do
        G.GAME.probabilities[k] = v * 2
      end
    end,
    blueprint_compat = false
}

SMODS.Joker {
    key = 'brownie',
    config = {
        extra = {
          retriggers = 2,
          retriggers_mod = 1,
        }
    },
    loc_txt = {
        name = "Two-Bite Brownie",
        text = {
          "Retrigger each played {C:attention}2{}",
          "{C:attention}#1#{} times",
          "{C:attention}-#2#{} per round played",
        },
    },
    atlas = 'Jokers',
    pos = {
      x = 0,
      y = 0
    },
    rarity = 1,
    cost = 4,
    calculate = function(self, card, context)
      if context.repetition and context.cardarea == G.play then
        if context.other_card:get_id() == 2 then 
          return {
              message = localize('k_again_ex'),
              repetitions = card.ability.extra.retriggers,
              card = card
          }
        end
      end
      if not context.blueprint and context.end_of_round and not context.repetition and not context.individual then
        if card.ability.extra.retriggers - card.ability.extra.retriggers_mod <= 0 then
          G.E_MANAGER:add_event(Event({
              func = function()
                  play_sound('tarot1')
                  card.T.r = -0.2
                  card:juice_up(0.3, 0.4)
                  card.states.drag.is = true
                  card.children.center.pinch.x = true
                  G.E_MANAGER:add_event(Event({
                      trigger = 'after',
                      delay = 0.3,
                      blockable = false,
                      func = function()
                          G.jokers:remove_card(card)
                          card:remove()
                          card = nil
                          return true;
                      end
                  }))
                  return true
              end
          }))
          return {
              message = localize('k_eaten_ex'),
              colour = G.C.IMPORTANT
          }
      else
          card.ability.extra.retriggers = card.ability.extra.retriggers - card.ability.extra.retriggers_mod
          return {
              message = tostring(card.ability.extra.retriggers),
              colour = G.C.IMPORTANT
          }
      end

      end
    end,
    loc_vars = function(self, info_queue, center)
      return { vars = { center.ability.extra.retriggers, center.ability.extra.retriggers_mod } }
    end,
    blueprint_compat = true,
    eternal_compat = false,
}

SMODS.Joker {
    key = 'buckleswasher',
    config = {
        extra = {
            mult = 1,
            mult_mod = 0.1
        }
    },
    loc_txt = {
        name = "Buckleswasher",
        text = {
          "Gives {X:mult,C:white}X#2#{} Mult per {C:money}${} of",
          "sell value of each owned",
          "{C:attention}Joker{} {C:red,E:1,S:0.3}right{} of this card",
          "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
        }
    },
    atlas = 'Jokers',
    pos = {
        x = 3,
        y = 3
    },
    rarity = 2,
    cost = 4,
    calculate = function(self, card, context)
      if context.joker_main and card.ability.extra.mult > 1 then
        return {
          message = localize{type='variable',key='a_xmult',vars={card.ability.extra.mult}},
          Xmult_mod = card.ability.extra.mult, 
          colour = G.C.MULT
        }
      end
    end,
    update = function(self, card, dt)
      local sell_cost = 0
      for i = #G.jokers.cards, 1, -1 do
          if G.jokers.cards[i] == card or (card.area and (card.area ~= G.jokers)) then
              break
          end
          sell_cost = sell_cost + G.jokers.cards[i].sell_cost
      end
      card.ability.extra.mult = 1 + math.max(0, sell_cost) * card.ability.extra.mult_mod
    end, 
    loc_vars = function(self, info_queue, center)
        return {
            vars = {center.ability.extra.mult, center.ability.extra.mult_mod}
        }
    end,
    blueprint_compat = true
}

SMODS.Joker {
    key = 'scouter',
    config = {
        extra = 0
    },
    loc_txt = {
        name = "Scouter",
        text = {
          "Sell this card to {C:attention}undo{}",
          "the last played hand.",
          "{C:inactive}(auto sells on death){}",
        }
    },
    atlas = 'Jokers',
    pos = {
        x = 9,
        y = 2
    },
    rarity = 2,
    cost = 5,
    calculate = function(self, card, context)
        if context.selling_self and (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.DRAW_TO_HAND) then
            G.E_MANAGER:add_event(Event({
                func = function()
                  ease_hands_played(1)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Undo"
                    });
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                blocking = true,
                trigger = 'ease',
                ref_table = G.GAME,
                ref_value = 'chips',
                ease_to = G.GAME.chips - math.floor(G.GAME.round_resets.jam_last_chips or 0), -- Going into debt on the first hand is intentional
                delay = 0.2,
                func = (function(t)
                    return math.floor(t)
                end)
            }))

            return nil, true
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {G.GAME.round_resets.jam_last_chips or 0}
        }
    end,
    blueprint_compat = true,
    eternal_compat = false,
}

SMODS.Joker {
    key = 'pierrot',
    loc_txt = {
        name = 'Pierrot',
        text = {
          "Allows for {C:attention}+#1#{} card to",
          "be selected and played"
        }
    },
    config = {
        extra = 1
    },
    atlas = 'Jokers',
    pos = {
        x = 5,
        y = 2
    },
    soul_pos = {
        x = 8,
        y = 3
    },
    rarity = 4,
    cost = 20,
    add_to_deck = function(self, card, from_debuff)
        G.hand.config.highlighted_limit = G.hand.config.highlighted_limit + card.ability.extra
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand.config.highlighted_limit = G.hand.config.highlighted_limit - card.ability.extra
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra}
        }
    end,
    blueprint_compat = false
}
