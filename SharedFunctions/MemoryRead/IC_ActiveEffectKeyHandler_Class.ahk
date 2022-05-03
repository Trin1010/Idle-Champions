; ActiveEffectKeyHandler finds base addresses for ActiveEffectKeyHandler classes such as BrivUnnaturalHasteHandler and imports the offsets used for them.
#include %A_LineFile%\..\IC_GameObjectStructure_Class.ahk
#include %A_LineFile%\..\IC_IdleGameManager_Class.ahk
class IC_ActiveEffectKeyHandler_Class
{
    ;NerdType := {0:"None", 1:"Fighter_Orange", 2:"Ranger_Red", 3:"Bard_Green", 4:"Cleric_Yellow", 5:"Rogue_Pink", 6:"Wizard_Purple"}
    HeroHandlerIDs := {"HavilarImpHandler":56, "BrivUnnaturalHasteHandler":58,"TimeScaleWhenNotAttackedHandler":47, "OminContraactualObligationsHandler":65, "NerdWagonHandler":87}
    HeroEffectNames := {"HavilarImpHandler":"havilar_imps", "BrivUnnaturalHasteHandler":"briv_unnatural_haste", "TimeScaleWhenNotAttackedHandler":"time_scale_when_not_attacked", "OminContraactualObligationsHandler": "contractual_obligations", "NerdWagonHandler":"nerd_wagon" }
    __new()
    {
        this.Refresh()
    }
 
    GetVersion()
    {
        return "v2.0, 2022-05-01, IC v0.430+"  
    }

    Refresh()
    {
        this.Main := new _ClassMemory("ahk_exe IdleDragons.exe", "", hProcessCopy)
        this.BrivUnnaturalHasteHandler := this.GetEffectHandler("BrivUnnaturalHasteHandler")
        this.HavilarImpHandler := this.GetEffectHandler("HavilarImpHandler")
        this.NerdWagonHandler := this.GetEffectHandler("NerdWagonHandler")
        this.OminContractualObligationsHandler := this.GetEffectHandler("OminContractualObligationsHandler")
        this.TimeScaleWhenNotAttackedHandler := this.GetEffectHandler("TimeScaleWhenNotAttackedHandler")
        if g_SF.Memory.GameManager.Is64Bit()
            this.Refresh64()
        else
            this.Refresh32()
    }

    Refresh32()
    {
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_BrivUnnaturalHasteHandler32_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_HavilarImpHandler32_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_NerdWagonHandler32_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_OminContractualObligationsHandler32_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_TimeScaleWhenNotAttackedHandler32_Import.ahk
    }

    Refresh64()
    {
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_BrivUnnaturalHasteHandler64_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_HavilarImpHandler64_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_NerdWagonHandler64_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_OminContractualObligationsHandler64_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_TimeScaleWhenNotAttackedHandler64_Import.ahk
    }

    GetEffectHandler(handlerName)
    {
        baseAddress := this.GetBaseAddress(handlerName)
        gameObject := New GameObjectStructure([])
        gameObject.BaseAddress := baseAddress
        return gameObject
    }

    GetBaseAddress(handlerName)
    {
        champID := this.HeroHandlerIDs[handlerName]
        tempObject := g_SF.Memory.GameManager.game.gameInstances.Controller.userData.HeroHandler.heroes.effects.effectKeysByKeyName.List.parentEffectKeyHandler.activeEffectHandlers.size.GetGameObjectFromListValues( 0, champID - 1, 0 )
        ; add dictionary value from effectkeysbyname
        currOffset := tempobject.CalculateDictOffset(["value", this.GetDictIndex(handlerName)]) + 0 
        tempObject.FullOffsets.InsertAt(15, currOffset)
        _size := g_SF.Memory.GenericGetValue(tempObject)
        ; Remove the "size" from the offsets list
        tempObject.FullOffsets.Pop()
        ; insert first list offset (Assuming only 1 item in activeEffectKeys list)
        tempObject.FullOffsets.Push(g_SF.Memory.GameManager.Is64Bit() ? 0x10 : 0x8) ; _items
        address := g_SF.Memory.GenericGetValue(tempObject) + tempObject.CalculateOffset(0)
        return address
    }

    ; Finds the index of the item in the dictionary by iterating the items looking for a key matching handlerName
    GetDictIndex(handlerName)
    {
        champID := this.HeroHandlerIDs[handlerName]
        effectName := this.HeroEffectNames[handlerName]
        tempObject := g_SF.Memory.GameManager.game.gameInstances.Controller.userData.HeroHandler.heroes.effects.effectKeysByKeyName.size.GetGameObjectFromListValues(0, ChampID - 1)
        dictCount := g_SF.Memory.GenericGetValue(tempObject)
        i := 0
        loop, % dictCount
        {
            tempObject := g_SF.Memory.GameManager.game.gameInstances.Controller.userData.HeroHandler.heroes.effects.effectKeysByKeyName.GetGameObjectFromListValues(0, ChampID - 1)
            currOffset := tempObject.CalculateDictOffset(["key", i])
            tempObject.FullOffsets.Push(currOffset)
            tempObject.ValueType := "UTF-16"
            keyName := g_SF.Memory.GenericGetValue(tempObject)
            if (keyName == effectName)
                return i
            ++i
        }
        return -1
    }
}


class ActiveEffectKeySharedFunctions
{
    class Havilar
    {
        class ImpHandler
        {
            GetCurrentOtherImpIndex()
            {
                return g_SF.Memory.GenericGetValue(g_SF.Memory.ActiveEffectKeyHandler.HavilarImpHandler.activeImps)
            }
            
            GetActiveImpsSize()
            {
                return g_SF.Memory.GenericGetValue(g_SF.Memory.ActiveEffectKeyHandler.HavilarImpHandler.currentOtherImpIndex)
            }

            GetSummonImpCoolDownTimer()
            {
                return g_SF.Memory.GenericGetValue(g_SF.Memory.ActiveEffectKeyHandler.HavilarImpHandler.summonImpUltimate.CoolDownTimer)
            }

            GetSacrificeImpCoolDownTimer()
            {
                return g_SF.Memory.GenericGetValue(g_SF.Memory.ActiveEffectKeyHandler.HavilarImpHandler.sacrificeImpUltimate.CoolDownTimer)
            }
        } 
    }

    class Briv
    {
        class BrivUnnaturalHasteHandler
        {
            ReadSkipChance()
            {
                return g_SF.Memory.GenericGetValue(g_SF.Memory.ActiveEffectKeyHandler.BrivUnnaturalHasteHandler.areaSkipChance)
            }
        }
    }

    Class Shandie
    {
        class TimeScaleWhenNotAttackedHandler
        {
            ReadDashActive()
            {
                return g_SF.Memory.GenericGetValue(g_SF.Memory.ActiveEffectKeyHandler.TimeScaleWhenNotAttackedHandler.scaleActive)
            }
        }
    }
}

; Omin Contractual Obligations
    ; ChampID := 65
    ; EffectKeyString := "contractual_obligations"
    ; RequiredLevel := 210
    ; EffectKeyID := 4110

; NerdWagon
    ; ChampID := 87
    ; EffectKeyString := "nerd_wagon"
    ; RequiredLevel := 80
    ; EffectKeyID := 921
    ; NerdType := {0:"None", 1:"Fighter_Orange", 2:"Ranger_Red", 3:"Bard_Green", 4:"Cleric_Yellow", 5:"Rogue_Pink", 6:"Wizard_Purple"}

; Havilar Imp Handler (HavilarImpHandler)
    ; ChampID := 56
    ; EffectKeyString := "havilar_imps"
    ; RequiredLevel := 15
    ; EffectKeyID := 3431

; Briv Unnatural haste (BrivUnnaturalHasteHandler)
    ; ChampID := 58
    ; EffectKeyString := "briv_unnatural_haste"
    ; RequiredLevel := 80
    ; EffectKeyID := 3452

; Shandie Dash (TimeScaleWhenNotAttackedHandler)
    ; ChampID := 47
    ; EffectKeyString := "time_scale_when_not_attacked"
    ; RequiredLevel := 120
    ; EffectKeyID := 2774