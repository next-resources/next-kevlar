# 🔰 Next Kevlar | Modular plate carriers

A fully modular Kevlar & plate carrier system for FiveM. Designed to integrate with `ox_inventory`. Perfect for realistic roleplay servers that want immersive armor mechanics.

---

## 🎯 Features

- ✅ Equip/unequip light and heavy plate carriers
- 🔄 Insert and remove armor plates via stash menu
- 🛡️ Dynamic damage system that tracks and applies damage to individual plates
- 💥 Plates can break and are visually represented
- 🗃️ Customizable plate types and carrier limits
- 🎨 Includes styled item icons (vests and plates)
- 📦 ox_inventory integration (temp stashes, metadata, tooltip display)
- 🚫 Anti-abuse protections and server-side validation
- ⚙️ Easy-to-edit config for vest visuals, limits, sync rules, etc.

---

## 📦 Dependencies

- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_lib](https://github.com/overextended/ox_lib)

---

## 🧰 Installation

1. **Download the latest release**

Unpack the release and remove the release tag so only `next-kevlar` remains. Make sure you add it to your resource.cfg for it to auto-start. *IMPORTANT: Make sure this resource starts AFTER ox_inventory!*

*Disclaimer: Do not edit the resource name, unless you are willing to adapt the script to it yourself. Some functions, like exports, depend on a set resource name. The current name is preconfigured.*

2. **Navigate to the installation folder**

Here, you'll find a premade config to paste into your `ox_inventory` `data/items.lua`. Premade items are also included. Drag these to `web/images`.

3. **Configure to your own liking**

All files within the `config` folder are easy to modify to your needs. Changing the `src` folder contents is only adviced if you are an avid developer yourself.

4. **Have Fun!**

The resource is now ready to use. You can add the items to shops, or give them via commands.

## 📦 Support / Reporting Bugs

This resource was tested thouroughly before release. Bugs could still exist. If you want to report a bug or require support, please join our Discord server.

Please remember to star this repository, and join our [discord](https://discord.nextextend.com)!
