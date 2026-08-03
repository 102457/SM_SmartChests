dofile( "$SURVIVAL_DATA/Scripts/game/survival_shapes.lua" )

ContainerUuids = {
	obj_container_gas,
	obj_container_battery,
	obj_container_water,
	obj_container_seed,
	obj_container_fertilizer,
	obj_container_ammo,
	obj_container_chest,
	obj_container_chest_looting,
	obj_container_chemical,
	obj_craftbot_refinery,
	obj_container_XXL_chest,
	obj_container_smallchest_pipe
}

PipeUuids = {
	obj_pneumatic_pipe_01,
	obj_pneumatic_pipe_02,
	obj_pneumatic_pipe_03,
	obj_pneumatic_pipe_04,
	obj_pneumatic_pipe_05,
	obj_pneumatic_pipe_bend,
	obj_pneumatic_pipe_t
}

for _,v in ipairs( ContainerUuids ) do assert( v ) end
for _,v in ipairs( PipeUuids ) do assert( v ) end

PipeState = { off = 1, invalid = 2, connected = 3, valid = 4 }

function RecursePipedShapeGraph( parent, setMarkedShapes, fnOnVertex )
	setMarkedShapes[parent.shape:getId()] = true
	for _, pipedShape in ipairs( parent.shape:getPipedNeighbours() ) do
		if setMarkedShapes[pipedShape:getId()] == nil then

			-- Set up new vertex in graph
			local vertex = {
				shape = pipedShape,
				childs = {},
				distance = parent.distance + 1,
				shapesOnPath = shallowcopy( parent.shapesOnPath ),
			}
			table.insert( vertex.shapesOnPath, pipedShape )
			table.insert( parent.childs, vertex )

			-- Callback to allow for custom traversal behaviours
			local recurse = true
			if fnOnVertex then
				recurse = fnOnVertex( vertex, parent )
			end

			if recurse then
				RecursePipedShapeGraph( vertex, setMarkedShapes, fnOnVertex )
			end
		end
	end
end

function ConstructPipedShapeGraph( shape, fnOnVertex )
	local setMarkedShapes = {}
	local root = { childs = {}, shape = shape, shapesOnPath = {}, distance = 0 }
	RecursePipedShapeGraph( root, setMarkedShapes, fnOnVertex )
end

--=====================================================================
-- SmartChests: item UUID -> special/dedicated container UUID mapping
--=====================================================================
local ItemSpecialContainer = {}

ItemSpecialContainer[tostring(obj_consumable_gas)] = obj_container_gas
ItemSpecialContainer[tostring(obj_consumable_battery)] = obj_container_battery
ItemSpecialContainer[tostring(obj_consumable_chemical)] = obj_container_chemical
ItemSpecialContainer[tostring(obj_consumable_water)] = obj_container_water
ItemSpecialContainer[tostring(obj_plantables_potato)] = obj_container_ammo
ItemSpecialContainer[tostring(obj_consumable_fertilizer)] = obj_container_fertilizer

-- seeds.json: all seed items go to the dedicated seed container
ItemSpecialContainer[tostring(obj_seed_banana)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_blueberry)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_orange)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_pineapple)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_carrot)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_redbeet)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_tomato)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_broccoli)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_potato)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_cotton)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_pigmentflower)] = obj_container_seed
ItemSpecialContainer[tostring(obj_seed_chili)] = obj_container_seed

-- paint colours: only allow items in if they belong to the category
local catagoryContainer = {}
--metal blocks grey
catagoryContainer["4a4a4aff"] = {blk_metal1, blk_metal2, blk_metal3, blk_scrapmetal, blk_beam, blk_crossnet,
								 blk_tryponet, blk_metalnet, blk_spaceshipmetal, blk_lights,
								 blk_metalbricks, blk_wornmetal, blk_framework, blk_treadplate,
								 blk_stripednet, blk_squarenet, blk_spaceshipfloor, blk_warehousefloor
								}
--wood blocks green
catagoryContainer["0e8031ff"] = {blk_cardboard, blk_wood1, blk_wood2, blk_wood3, blk_scrapwood, blk_caution}
--stone blocks yellow
catagoryContainer["817c00ff"] = {blk_sand, blk_concrete1, blk_concrete2, blk_concrete3, blk_scrapstone,
						blk_bricks, blk_glass, blk_armoredglass, blk_glasstile, blk_tiles,
						blk_crackedconcrete, blk_concretetiles
					}
--other blocks lime
catagoryContainer["577d07ff"] = {blk_carpet, blk_plastic, blk_bubblewrap,
						blk_insulation, blk_drywall, blk_plasticwall, blk_fancycarpet, blk_ice
					}
--pipes & fittings blue (full fittings.json set, corrected small-pipe names)
catagoryContainer["0f2e91ff"] = {
						obj_fittings_ductshort, obj_fittings_ductlong, obj_fittings_ductbend, obj_fittings_ductintersect,
						obj_fittings_ductelevate, obj_fittings_ductpipe, obj_fittings_ac, obj_fittings_pipe, obj_fittings_pipelong,
						obj_fittings_pipebend, obj_fittings_pipesplit, obj_fittings_pipevalve, obj_fittings_pipebig,
						obj_fittings_pipebiglong, obj_fittings_pipebigbend, obj_fittings_pipebigsplit, obj_fittings_wireshort,
						obj_fittings_wire, obj_fittings_wirebend, obj_fittings_wireconvexbend, obj_fittings_wireconcavebend,
						obj_fittings_fusebox, obj_fittings_cordstraight, obj_fittings_cordstraightlong, obj_fittings_cordbend,
						obj_fittings_cordjunction, obj_small_2way_pipe, obj_small_long_pipe, obj_small_2wayb_pipe,
						obj_small_3way_pipe, obj_small_3wayb_pipe, obj_small_4way_pipe, obj_small_4wayb_pipe, obj_small_5way_pipe,
						obj_small_6way_pipe, obj_fittings_pipebigshort, obj_fittings_pipebigholder, obj_fittings_pipebigholderbar,
						obj_fittings_pipebigholderbarbend, obj_fittings_pipebigwallconnector, obj_fittings_pipebiglid,
						obj_fittings_pipebigtank, obj_fittings_powerstation, obj_fittings_7x8, obj_fittings_7x8_glass,
						obj_fittings_7x8_bend, obj_fittings_7x8_bend_glass, obj_fittings_7x8_T, obj_fittings_7x1,
						obj_fittings_7x8_mount, obj_fittings_ventbig01, obj_fittings_ventbig02, obj_fittings_ventbig03,
						obj_fittings_ventbig04, obj_fittings_ventbig05, obj_fittings_venthub, obj_fittings_generatorpipe,
						obj_fittings_generatorpipelong, obj_fittings_generatorpipebend, obj_fittings_generatorpipesplit,
						obj_fittings_generatorpipemulti
					}
--vehicle parts red
catagoryContainer["7c0000ff"] = {obj_interactive_driversaddle_01, obj_interactive_driversaddle_02, obj_interactive_driversaddle_03, obj_interactive_driversaddle_04, obj_interactive_driversaddle_05,
						obj_interactive_driverseat_01, obj_interactive_driverseat_02, obj_interactive_driverseat_03, obj_interactive_driverseat_04, obj_interactive_driverseat_05,
						obj_interactive_seat_01, obj_interactive_seat_02, obj_interactive_seat_03, obj_interactive_seat_04, obj_interactive_seat_05,
						obj_interactive_saddle_01, obj_interactive_saddle_02, obj_interactive_saddle_03, obj_interactive_saddle_04, obj_interactive_saddle_05,
						obj_interactive_gasengine_01, obj_interactive_gasengine_02, obj_interactive_gasengine_03, obj_interactive_gasengine_04, obj_interactive_gasengine_05,
						obj_interactive_electricengine_01, obj_interactive_electricengine_02, obj_interactive_electricengine_03, obj_interactive_electricengine_04, obj_interactive_electricengine_05,
						obj_interactive_thruster_01, obj_interactive_thruster_02, obj_interactive_thruster_03, obj_interactive_thruster_04, obj_interactive_thruster_05,
						jnt_suspensionoffroad_01, jnt_suspensionoffroad_02, jnt_suspensionoffroad_03, jnt_suspensionoffroad_04, jnt_suspensionoffroad_05,
						jnt_suspensionsport_01, jnt_suspensionsport_02, jnt_suspensionsport_03, jnt_suspensionsport_04, jnt_suspensionsport_05,
						jnt_interactive_piston_01, jnt_interactive_piston_02, jnt_interactive_piston_03, jnt_interactive_piston_04, jnt_interactive_piston_05,
						obj_interactive_mountablespudgun, jnt_bearing, obj_vehicle_smallwheel, obj_vehicle_bigwheel,
						obj_scrap_gasengine, obj_scrap_driverseat, obj_scrap_seat, obj_scrap_smallwheel
					}
--logic parts orange
catagoryContainer["673b00ff"] = {obj_interactive_controller_01, obj_interactive_controller_02, obj_interactive_controller_03, obj_interactive_controller_04, obj_interactive_controller_05,
						jnt_interactive_piston_01, jnt_interactive_piston_02, jnt_interactive_piston_03, jnt_interactive_piston_04, jnt_interactive_piston_05,
						obj_interactive_sensor_01,  obj_interactive_sensor_02, obj_interactive_sensor_03, obj_interactive_sensor_04, obj_interactive_sensor_05,
						obj_interactive_switch, obj_interactive_button, obj_interactive_logicgate, obj_interactive_timer
					}

-- New categories (32 assigned; eeaf5cff reserved/unused, freed up from scrap.json merge into vehicle parts)
--Industrial structural
catagoryContainer["118787ff"] = {
							obj_industrial_beam, obj_industrial_beamlong, obj_industrial_beambend, obj_industrial_beamelevation,
							obj_industrial_beamend, obj_industrial_beamshelf, obj_industrial_platform, obj_industrial_platformfencelong,
							obj_industrial_platformfenceshort, obj_industrial_platformfencepole, obj_industrial_platformfenceconnector,
							obj_industrial_stairplatform, obj_industrial_stairfence, obj_industrial_stairwedge,
							obj_industrial_platformstairsramp, obj_industrial_metalgrid, obj_industrial_railing,
							obj_industrial_metalsupport, obj_industrial_supportxframe, obj_industrial_supportvframe,
							obj_industrial_support_quater_frame, obj_industrial_supportbeam, obj_industrial_supportpillar,
							obj_industrial_supportxbeam, obj_industrial_supportbeambase, obj_industrial_rack, obj_industrial_rackcube,
							obj_industrial_racklong, obj_industrial_cylindersmall, obj_industrial_cylindermedium,
							obj_industrial_cylinderlarge, obj_industrial_window, obj_industrial_pallet, obj_industrial_rail,
							obj_industrial_antennatower, obj_industrial_antennatowertop, obj_industrial_satellite01,
							obj_industrial_satellite03, obj_industrial_antenna01, obj_industrial_antenna02, obj_industrial_windowglass01,
							obj_industrial_windowglass02, obj_industrial_windowglass03, obj_industrial_windshieldlarge,
							obj_industrial_windshield, obj_industrial_rooftankslice, obj_industrial_rooftankslicetop,
							obj_industrial_windowframe, obj_industrial_generatorfoothinge, obj_industrial_encryptstandbase,
							obj_industrial_encryptstandfoundation, obj_industrial_encryptstandframe, obj_industrial_encryptstandhinge,
							obj_industrial_encryptstandpillar, obj_industrial_encryptstandpipe, obj_industrial_encryptstandside,
							obj_industrial_powergenerator5, obj_industrial_powergenerator4, obj_industrial_powergenerator2,
							obj_industrial_powergenerator1, obj_industrial_powergeneratorside, obj_industrial_powergeneratortank,
							obj_industrial_powergenerator7, obj_industrial_powerswitch, obj_industrial_powerholders,
					}

--Casted & construction parts
catagoryContainer["500aa6ff"] = {
							obj_castedpart_t1, obj_castedpart_t2, obj_castedpart_t3, obj_castedpart_t4, obj_castedpart_t5,
							obj_construction_brick, obj_construction_rebarsmall, obj_construction_rebarmedium, obj_construction_rebarbig,
							obj_construction_signcone, obj_construction_signcone_taped, obj_construction_bucket, obj_construction_mould,
							obj_construction_carpetroll, obj_construction_carpetrollstand, obj_construction_wall02,
							obj_construction_wallpillar, obj_construction_wallfondation, obj_construction_wallplank,
							obj_construction_ramp01, obj_construction_ramp02, obj_construction_soundisolationsmall,
							obj_construction_soundisolation, obj_construction_light, obj_construction_paintcan, obj_construction_stairs,
					}

--Craftbot components
catagoryContainer["720a74ff"] = {
							obj_craftbot_cookbot, obj_craftbot_craftbot1, obj_craftbot_craftbot2, obj_craftbot_craftbot3,
							obj_craftbot_craftbot4, obj_craftbot_craftbot5, obj_craftbot_refinery, obj_craftbot_resourcecontainer,
							obj_craftbot_dressbot, obj_craftbot_portablecraftbot, obj_vehicle_gripwheel_x7, obj_vehicle_gripwheel_x9,
							obj_rewards_lowriderwheel,
					}

--Tools
catagoryContainer["7f7f7fff"] = {
							obj_tool_bucket_empty, obj_tool_bucket_water, obj_tool_bucket_chemical, obj_tool_bucket_oil, tool_handbook,
							tool_sledgehammer, tool_lift, tool_connect, tool_paint, tool_weld, tool_spudgun, tool_shotgun, tool_gatling,
							tool_scrap_spudgun, tool_launcher, tool_claygun, obj_tool_sledgehammer, obj_tool_connect, obj_tool_paint,
							obj_tool_weld, obj_tool_spudgun, obj_tool_spudling, obj_tool_frier, obj_tool_handbook,
							obj_tool_scrap_spudgun, obj_tool_launcher,
					}

--Power tools
catagoryContainer["e2db13ff"] = {
							obj_powertools_sawblade, obj_powertools_drill, obj_interactive_plasmadrill_lvl1,
							obj_interactive_plasmadrill_lvl2, obj_interactive_plasmadrill_lvl3,
					}

--Robot parts
catagoryContainer["a0ea00ff"] = {
							obj_robotparts_tapebotshooter, obj_robotparts_minerbot_thruster,
					}

--Vehicle attachments
catagoryContainer["19e753ff"] = {
							obj_vehicle_smallwheel, obj_vehicle_bigwheel, obj_vehicle_license_plate, obj_vehicle_mediumpipe,
							obj_vehicle_mediumpipebent, obj_vehicle_wheelhousecorner, obj_vehicle_concavewedge,
					}

--Appliances
catagoryContainer["2ce6e6ff"] = {
							obj_interactive_fridge, obj_interactive_locker, obj_interactive_filecabinet, obj_interactive_stafftoilet,
					}

--Building fixtures
catagoryContainer["0a3ee2ff"] = {
							obj_building_barracksupport, obj_building_barracksupportlong, obj_building_barracksupportturn,
							obj_building_barracksupportholder, obj_building_barracksupportbase, obj_building_mopbucket,
							obj_building_stalldoor, obj_building_slippery, obj_building_plunger, obj_building_sink,
					}

--Container items
catagoryContainer["7514edff"] = {
							obj_container_gas, obj_container_water, obj_container_fertilizer, obj_container_battery, obj_container_ammo,
							obj_container_seed, obj_container_chemical, obj_container_chest, obj_container_chest_looting,
							obj_container_smallchest, obj_container_tinychest, obj_container_XXL_chest, obj_container_smallchest_pipe,
					}

--Survival/facility gear
catagoryContainer["cf11d2ff"] = {
							obj_survivalobject_keycard, obj_survivalobject_cardreader, obj_survivalobject_cardreader_arm,
							obj_packingstation_front, obj_packingstation_mid, obj_packingstation_crateload,
							obj_packingstation_screen_fruit, obj_packingstation_screen_veggie, obj_smelter_deposit,
							obj_survivalobject_elevatorfloor, obj_survivalobject_elevatorbutton, obj_survivalobject_elevatorcallbutton,
							obj_survivalobject_elevatordoor_left, obj_survivalobject_bananabox, obj_survivalobject_elevatorlamp,
							obj_survivalobject_elevatorwallleft, obj_survivalobject_elevatorwallright, obj_survivalobject_elevatorfan,
							obj_survivalobject_elevatorceiling, obj_survivalobject_workbench, obj_survivalobject_capsuledoor,
							obj_survivalobject_powercoresocket, obj_survivalobject_powercore, obj_survivalobject_dispenserbot,
							obj_survivalobject_dispenserbot_spawner, obj_survivalobject_terminal, obj_hideout_questgiver,
							obj_hideout_button, obj_hideout_dropoff, obj_survivalobject_kobag, obj_survivalobject_ruinchest,
							obj_survivalobject_minidungeon_keycard, obj_survivalobject_topdepcardreader,
							obj_survivalobject_keylock_growlab, obj_underground_key, obj_powerstation_battery,
							obj_survivalobject_mininghub_dispenserbot, obj_survivalobject_platformspawner, obj_growlab_key,
							obj_survivalobject_mustache, obj_questitem_pictureframe, obj_survivalobject_garageconsole,
							obj_survivalobject_garagechest, obj_survivalobject_excavationelevatorbutton,
							obj_survivalobject_partunlockstation, obj_survivalobject_shipcompartment, obj_survivalobject_vendor,
							obj_interactive_bed_tutorial,
					}

--Wedges (all materials)
catagoryContainer["d02525ff"] = {
							wdg_concrete1, wdg_wood1, wdg_metal1, wdg_caution, wdg_tiles, wdg_bricks, wdg_glass, wdg_glasstile,
							wdg_lights, wdg_spaceshipmetal, wdg_cardboard, wdg_scrapwood, wdg_wood2, wdg_wood3, wdg_scrapmetal,
							wdg_metal2, wdg_metal3, wdg_scrapstone, wdg_concrete2, wdg_concrete3, wdg_crackedconcrete, wdg_concretetiles,
							wdg_metalbricks, wdg_beam, wdg_bubblewrap, wdg_plastic, wdg_insulation, wdg_drywall, wdg_carpet,
							wdg_plasticwall, wdg_metalnet, wdg_crossnet, wdg_tryponet, wdg_stripednet, wdg_squarenet, wdg_restroom,
							wdg_treadplate, wdg_warehousefloor, wdg_wornmetal, wdg_spaceshipfloor, wdg_sand, wdg_armoredglass,
							wdg_fancycarpet, wdg_undergroundstation4x, wdg_ice, wdg_dekotora,
					}

--Structural/architecture blocks
catagoryContainer["df7f00ff"] = {
							obj_structure_postalcrate, obj_structure_freightshell, obj_structure_freightcrate, obj_structure_woodstairs,
							obj_structure_cableroll03, obj_structure_concretefoundation01, obj_structure_concretefoundation02,
							obj_structure_concretepillar, obj_structure_concretebarrier, obj_structure_concretebarrier02,
							obj_structure_metalcube, obj_structure_metalcanisterframe, obj_structure_metalbeam,
							obj_structure_metalbarrier, obj_structure_metalstairs, obj_topdepartment_chair, obj_topdepartment_chair_foot,
							obj_warehouse_beambig, obj_warehouse_beambiglong, obj_warehouse_beambigturn, obj_warehouse_beambigbend,
							obj_warehouse_beambigsplit, obj_warehouse_beambigintersect, obj_warehouse_beambigend,
							obj_warehouse_beamframe, obj_warehouse_beamframelong, obj_warehouse_beamframeend,
							obj_warehouse_beamframeturn, obj_warehouse_bigramp, obj_warehouse_bigrampsmall, obj_warehouse_bigrampthin,
							obj_warehouse_bigrampthinsmall, obj_warehouse_container1, obj_warehouse_container2, obj_warehouse_container3,
							obj_warehouse_container3B, obj_warehouse_container3C, obj_warehouse_container4, obj_warehouse_container5,
							obj_warehouse_container6, obj_warehouse_container7, obj_warehouse_fan, obj_warehouse_fancube,
							obj_warehouse_fanblade, obj_warehouse_packingtable, obj_warehouse_packingtablesupport,
							obj_warehouse_packingtablesign, obj_warehouse_packingtableroll, obj_warehouse_banner1, obj_warehouse_banner2,
							obj_warehouse_doorframelight, obj_warehouse_overheadcranearm, obj_warehouse_overheadcranearmplate,
							obj_warehouse_overheadcranerope, obj_warehouse_overheadcranearmplatform, obj_warehouse_overheadcranetrolley,
							obj_warehouse_cranehook, obj_warehouse_cranehook_base, obj_warehouse_craneplatform,
							obj_warehouse_encryptorsign_destruction, obj_warehouse_encryptorsign_connection, obj_warehouse_masterswitch,
							obj_construction_light_warehouse, obj_warehouse_elevatorsign, obj_spaceship_exitsign, obj_spaceship_shipdoor,
							obj_spaceship_ceilinglight, obj_spaceship_interiorhandle, obj_spaceship_interiorcables,
							obj_spaceship_interiorwedgelong, obj_spaceship_interiorboxmedium, obj_spaceship_interiorboxlarge,
							obj_spaceship_interiorlight, obj_spaceship_interiornet, obj_spaceship_interiornetlarge,
							obj_spaceship_interiorshelf, obj_spaceship_interiorcalendar, obj_spaceship_shipbed, obj_spaceship_microwave,
							obj_spaceship_cranewheel, obj_spaceship_wall08, obj_spaceship_wall08_damaged, obj_spaceship_wall02,
							obj_spaceship_wall02_damaged, obj_spaceship_wall01, obj_spaceship_wall03, obj_spaceship_wall04,
							obj_spaceship_wall12, obj_spaceship_wall12_damaged, obj_spaceship_wall06, obj_spaceship_wall05,
							obj_spaceship_corner01, obj_spaceship_corner01_damaged, obj_spaceship_corner02, obj_spaceship_corner03,
							obj_spaceship_wall11, obj_spaceship_wall09, obj_spaceship_wall10, obj_spaceship_ceilingbeam03,
							obj_spaceship_ceilingbeam01, obj_spaceship_ceilingbeam02, obj_spaceship_frame01, obj_spaceship_frame02,
							obj_spaceship_frame05, obj_spaceship_frame03, obj_spaceship_frame04, obj_spaceship_frame06,
							obj_spaceship_blinds, obj_spaceship_ceilingvent01, obj_spaceship_ceilingvent02, obj_spaceship_floor_panel,
							obj_spaceship_infoboard, obj_spaceshipsurvivalobject_shipbed, blk_undergroundstation,
							blk_undergroundstation2x, blk_undergroundstation4x,
					}

--Ores & nuggets
catagoryContainer["eeeeeeff"] = {
							obj_nugget_t1, obj_nugget_t2, obj_nugget_t3, obj_nugget_t4, obj_nugget_t5, obj_moltenorb_t1,
							obj_moltenorb_t2, obj_moltenorb_t3, obj_moltenorb_t4, obj_moltenorb_t5,
					}

--Raw gems & crystals
catagoryContainer["f5f071ff"] = {
							obj_resource_quartz, obj_resource_coralium, obj_resource_nimbolium, obj_resource_lemonium,
							obj_resource_sapphire, obj_resource_crystal, obj_resource_refinedcoralium, obj_resource_refinednimbolium,
							obj_resource_refinedlemonium, obj_resource_refinedsapphire, obj_resource_refinedcrystal,
					}

--Organic resources
catagoryContainer["cbf66fff"] = {
							obj_resource_beewax, obj_resource_ember, obj_resource_crudeoil, obj_resource_cotton, obj_resource_corn,
							obj_resources_slimyclam, obj_resource_flower, obj_resource_glowpoop, obj_resource_mud, obj_resource_silica,
							obj_resource_circuitboard, obj_resource_residueore, obj_resource_wonkstonks, obj_resource_drillcasingt1,
							obj_resource_drillcasingt3, obj_resource_drillcasingt4, obj_resource_drillcasingrich,
							obj_resource_drillcasingmixedt1, obj_resource_drillcasingmixedt3, obj_resource_drillcasingmixedt4,
							obj_resource_drillcasingmixedrich,
					}

--Harvestable chunks
catagoryContainer["68ff88ff"] = {
							obj_harvest_wood, obj_harvest_wood2, obj_harvest_metal, obj_harvest_metal2, obj_harvest_stone,
							obj_harvest_quartz, obj_harvest_lemonium, obj_harvests_nonepart_sapphire, obj_harvests_nonepart_sapphire_p01,
							obj_harvests_nonepart_sapphire_p02, obj_harvests_nonepart_sapphire_p03, obj_harvests_nonepart_sapphire_p04,
							obj_harvests_nonepart_sapphire_p05, obj_harvests_nonepart_sapphire_p06, obj_harvests_nonepart_sapphire_p07,
							obj_harvests_nonepart_sapphire_p08, obj_harvests_nonepart_tier5, obj_harvests_nonepart_tier5_p01,
							obj_harvests_nonepart_tier5_p02, obj_harvests_nonepart_tier5_p03, obj_harvests_nonepart_tier5_p04,
							obj_harvests_nonepart_tier5_p05, obj_harvests_nonepart_tier5_p06, obj_harvests_nonepart_tier5_p07,
							obj_harvests_nonepart_tier5_p08,
					}

--Stone parts/rubble
catagoryContainer["7eededff"] = {
							obj_harvests_stones_p01, obj_harvests_stones_p02, obj_harvests_stones_p03, obj_harvests_stones_p04,
							obj_harvests_stones_p05, obj_harvests_stones_p06, obj_harvest_stonechunk01, obj_harvest_stonechunk02,
							obj_harvest_stonechunk03,
					}

--Crops (plantables)
catagoryContainer["4c6fe3ff"] = {
							obj_plantables_banana, obj_plantables_blueberry, obj_plantables_orange, obj_plantables_pineapple,
							obj_plantables_carrot, obj_plantables_redbeet, obj_plantables_tomato, obj_plantables_broccoli,
							obj_plantables_potato, obj_plantables_chili,
					}

--Food & drink
catagoryContainer["ae79f0ff"] = {
							obj_consumable_sunshake, obj_consumable_carrotburger, obj_consumable_pizzaburger,
							obj_consumable_longsandwich, obj_consumable_milk, obj_consumable_tea,
					}

--Crafting consumables
catagoryContainer["ee7bf0ff"] = {
							obj_consumable_component, obj_consumable_multicomponent, obj_consumable_clay, obj_consumables_cableroll,
							obj_consumable_soilbag, obj_consumable_glue,
					}

--Ammo & combat consumables
catagoryContainer["f06767ff"] = {
							obj_consumable_inkammo, obj_consumable_cornade, obj_consumable_fireammo, obj_consumable_extinguisher,
							obj_consumable_glowstick,
					}

--Terrain/voxel materials
catagoryContainer["222222ff"] = {
							obj_voxelmaterial_rich, obj_voxelmaterial_t1, obj_voxelmaterial_t3, obj_voxelmaterial_t4,
							obj_voxelmaterialchunk_rich1_small, obj_voxelmaterialchunk_rich1_medium, obj_voxelmaterialchunk_rich1_large,
							obj_voxelmaterialchunk_rich2_small, obj_voxelmaterialchunk_rich2_medium, obj_voxelmaterialchunk_rich2_large,
							obj_voxelmaterialchunk_t1_small, obj_voxelmaterialchunk_t1_medium, obj_voxelmaterialchunk_t1_large,
							obj_voxelmaterialchunk_t3_small, obj_voxelmaterialchunk_t3_medium, obj_voxelmaterialchunk_t3_large,
							obj_voxelmaterialchunk_t4_small, obj_voxelmaterialchunk_t4_medium, obj_voxelmaterialchunk_t4_large,
					}

--Tree parts - logs
catagoryContainer["323000ff"] = {
							obj_harvest_log_s01, obj_harvest_log_m01, obj_harvest_log_l01, obj_harvest_log_l02a, obj_harvest_log_l02b,
					}

--Tree parts - leaves/foliage
catagoryContainer["375000ff"] = {
							obj_harvests_trees_spruce02_p00, obj_harvests_trees_spruce02_p01, obj_harvests_trees_spruce02_p02,
							obj_harvests_trees_spruce02_p03, obj_harvests_trees_spruce02_p04, obj_harvests_trees_spruce01_p05,
							obj_harvests_trees_spruce02_p05, obj_harvests_trees_spruce03_p05, obj_harvests_trees_leafy01_p00,
							obj_harvests_trees_leafy01_p01, obj_harvests_trees_leafy01_p02, obj_harvests_trees_leafy01_p03,
							obj_harvests_trees_leafy01_p04, obj_harvests_trees_leafy02_p00, obj_harvests_trees_leafy02_p01,
							obj_harvests_trees_leafy02_p02, obj_harvests_trees_leafy02_p03, obj_harvests_trees_leafy02_p04,
							obj_harvests_trees_leafy02_p05, obj_harvests_trees_leafy02_p06, obj_harvests_trees_leafy02_p07,
							obj_harvests_trees_leafy03_p00, obj_harvests_trees_leafy03_p01, obj_harvests_trees_leafy03_p02,
							obj_harvests_trees_leafy03_p03, obj_harvests_trees_leafy03_p04, obj_harvests_trees_leafy03_p05,
							obj_harvests_trees_leafy03_p06, obj_harvests_trees_leafy03_p07, obj_harvests_trees_leafy03_p08,
							obj_harvests_trees_leafy03_p09, obj_harvests_trees_birch01_p00, obj_harvests_trees_birch01_p01,
							obj_harvests_trees_birch01_p02, obj_harvests_trees_birch01_p03, obj_harvests_trees_birch01_p04,
							obj_harvests_trees_birch01_p05, obj_harvests_trees_birch02_p00, obj_harvests_trees_birch02_p01,
							obj_harvests_trees_birch02_p02, obj_harvests_trees_birch02_p03, obj_harvests_trees_birch02_p04,
							obj_harvests_trees_birch02_p05, obj_harvests_trees_birch02_p06, obj_harvests_trees_birch03_p00,
							obj_harvests_trees_birch03_p01, obj_harvests_trees_birch03_p02, obj_harvests_trees_birch03_p03,
							obj_harvests_trees_birch03_p04, obj_harvests_trees_birch03_p05, obj_harvests_trees_birch03_p06,
							obj_harvests_trees_pine01_p00, obj_harvests_trees_pine01_p01, obj_harvests_trees_pine01_p02,
							obj_harvests_trees_pine01_p03, obj_harvests_trees_pine01_p04, obj_harvests_trees_pine01_p05,
							obj_harvests_trees_pine01_p06, obj_harvests_trees_pine01_p07, obj_harvests_trees_pine01_p08,
							obj_harvests_trees_pine01_p09, obj_harvests_trees_pine01_p10, obj_harvests_trees_pine01_p11,
							obj_harvests_trees_pine02_p00, obj_harvests_trees_pine02_p01, obj_harvests_trees_pine02_p02,
							obj_harvests_trees_pine02_p03, obj_harvests_trees_pine02_p04, obj_harvests_trees_pine02_p05,
							obj_harvests_trees_pine02_p06, obj_harvests_trees_pine02_p07, obj_harvests_trees_pine02_p08,
							obj_harvests_trees_pine02_p09, obj_harvests_trees_pine02_p10, obj_harvests_trees_pine03_p00,
							obj_harvests_trees_pine03_p01, obj_harvests_trees_pine03_p02, obj_harvests_trees_pine03_p03,
							obj_harvests_trees_pine03_p04, obj_harvests_trees_pine03_p05, obj_harvests_trees_pine03_p06,
							obj_harvests_trees_pine03_p07, obj_harvests_trees_pine03_p08, obj_harvests_trees_pine03_p09,
							obj_harvests_trees_pine03_p10,
					}

--Lighting fixtures
catagoryContainer["064023ff"] = {
							obj_light_headlight, obj_light_beamframelight, obj_light_factorylamp, obj_light_packingtablelamp,
							obj_light_fluorescentlamp, obj_light_arealight, obj_light_posterspotlight, obj_light_posterspotlight2,
							obj_light_rangelight, obj_light_rangelightlarge,
					}

--Manmade decor
catagoryContainer["0a4444ff"] = {
							obj_manmade_scrapwall01, obj_manmade_scrapwallsmall, obj_manmade_scraproof01, obj_manmade_scraproof02,
							obj_manmade_scraproof03, obj_manmade_shacklight, obj_manmade_freshsign, obj_manmade_holidayposter,
							obj_manmade_salesign,
					}

--Potted plants
catagoryContainer["0a1d5aff"] = {
							obj_plants_growbox, obj_plants_leafplant, obj_plants_succulent, obj_plants_poleplant, obj_plants_bigpot,
							obj_plants_seedplant, obj_plants_ballcactus, obj_plants_barbarycactus, obj_plants_blueflower,
					}

--Decorative containers
catagoryContainer["35086cff"] = {
							obj_containers_woodbox, obj_containers_vegboxgreen, obj_containers_vegboxcucumber,
							obj_containers_vegboxcarrot, obj_containers_vegboxbanana, obj_containers_smallbox, obj_containers_vegboxblue,
							obj_containers_vegboxonion, obj_containers_vegboxbeetroot, obj_containers_vegboxorange,
							obj_containers_plantcontainerclosed, obj_containers_plantcontaineropen, obj_containers_haycrate,
							obj_containers_stonecrate, obj_containers_treecrate, obj_containers_cowcrate,
							obj_containers_cardboardstack_small, obj_containers_cardboardstack_medium,
							obj_containers_cardboardstack_large, obj_containers_humidifier, obj_containers_stack,
							obj_containers_barrel_blueberry, obj_containers_barrel_tomato,
					}

--Tape/barriers
catagoryContainer["520653ff"] = {
							obj_destructable_tape_doorwaytape01, obj_destructable_tape_doorwaytape01_destroyed,
							obj_destructable_tape_cornertape01, obj_destructable_tape_cornertape02, obj_destructable_tape_cornertape03,
							obj_destructable_tape_cornertape04, obj_destructable_tape_corridor01, obj_destructable_tape_corridor02,
							obj_destructable_tape_corridor03, obj_destructable_tape_taperoll01, obj_destructable_tape_taperoll02,
							obj_destructable_tape_taperoll03, obj_destructable_tape_taperoll04, obj_destructable_tape_tape01,
							obj_destructable_tape_tape02, obj_destructable_tape_tape03, obj_destructable_tape_tape04,
							obj_destructable_tape_tape05, obj_destructable_tape_tape06, obj_destructable_tape_cocoon01,
							obj_destructable_tape_cocoon02, obj_destructable_tape_rooftape01, obj_destructable_tape_rooftape02,
							obj_destructable_tape_rooftape03, obj_destructable_tape_rooftape04, obj_destructable_tape_acrosstheroom01,
							obj_destructable_tape_acrosstheroom02, obj_destructable_tape_acrosstheroom03,
							obj_destructable_tape_big_walltape01, obj_destructable_tape_big_walltape02,
							obj_destructable_tape_big_walltape03, obj_destructable_tape_big_walltape04,
							obj_destructable_tape_big_walltape05,
					}

--Jewelry & artifacts
catagoryContainer["560202ff"] = {
							obj_jewel_01, obj_jewel_02, obj_jewel_03, obj_jewel_04, obj_artifact_fossil01, obj_artifact_fossil05,
							obj_artifact_fossil08, obj_artifact_fossil09, obj_artifact_fossil11, obj_artifact_fossil11b,
							obj_artifact_fossil11c, obj_artifact_fossil13,
					}

--Rewards & loot
catagoryContainer["472800ff"] = {
							obj_rewards_doorhandle, obj_shoprewards_farmbotbobblehead, obj_shoprewards_scrapmechanicbobblehead,
							obj_shoprewards_scrapmechanicbobbleheadfemale, obj_shoprewards_spaceshipstatue,
							obj_shoprewards_totebotbass_bobblehead, obj_shoprewards_totebotpercussion_bobblehead,
							obj_shoprewards_totebotsynthvoice_bobblehead, obj_shoprewards_totebotblip_bobblehead,
							obj_shoprewards_goldplatinumbearing, obj_shoprewards_lowriderplaque, obj_shoprewards_fountainstatue,
							obj_shoprewards_bonsaitree, obj_rewards_fireworks, obj_rewards_tablelamp, obj_rewards_kitchenpot01,
							obj_rewards_lavalamp, obj_rewards_plant01, obj_rewards_plant02, obj_rewards_plant03, obj_rewards_window,
							obj_rewards_pictureframe, obj_rewards_modularsofa01, obj_rewards_modularsofa02, obj_rewards_coffepot,
							obj_rewards_backmirror, obj_rewards_sidemirror, obj_rewards_bowl, obj_rewards_10pin, obj_rewards_bowlingball,
							obj_rewards_anvil, obj_rewards_ivypipe01, obj_rewards_ivypipe02, obj_rewards_ivypipe04,
							obj_rewards_carfrontpanel, obj_rewards_carbumper, obj_rewards_windshield, obj_rewards_carbackpanel,
							obj_rewards_beachball, obj_shoprewards_computer, obj_shoprewards_synth, obj_shoprewards_gasstove,
							obj_rewards_safe, obj_crates_banana, obj_crates_blueberry, obj_crates_orange, obj_crates_pineapple,
							obj_crates_carrot, obj_crates_redbeet, obj_crates_tomato, obj_crates_broccoli, obj_survivalobject_farmerball,
							obj_outfitpackage_common, obj_outfitpackage_rare, obj_outfitpackage_epic, obj_shootingrange_farmertarget,
							obj_shootingrange_farmbottarget,
					}

local function evaluateChestPriority( container, itemUid )
	-- container is the unique/dedicated container type for this item
	if container.shape.uuid == ItemSpecialContainer[tostring(itemUid)] then
		return 4
	end
	local color = tostring( container.shape.color )
	-- container is limited by category and item matches
	if catagoryContainer[color] and isAnyOf( itemUid, catagoryContainer[color] ) then
		return 2
	end
	-- container has no limits on item type
	return 1
end

function FindContainerToCollectTo( containers, itemUid, amount )
	print("SMARTCHESTS: FindContainerToCollectTo called, itemUid=" .. tostring(itemUid) .. " containers=" .. tostring(#containers))
	local chestPriority = 0
	local chest = nil
	for _, container in ipairs( containers ) do
		if sm.container.canCollect( container.shape:getInteractable():getContainer(), itemUid, amount ) then
			local v = evaluateChestPriority( container, itemUid )
			-- if current container is the new best, remember it
			if chestPriority < v then
				chestPriority = v
				chest = container
			end
		end
	end
	return chest
end

-- SmartChests: shared wrapper around FindContainerToCollectTo so any caller
-- (Crafter.lua, Vacuum.lua, etc.) can get priority/color-aware container
-- selection instead of calling the vanilla sm.pipeGraph.getContainerShapeToCollectTo
-- black box directly. Builds the candidate list from getOutputContainers
-- (same list the engine call reads internally), and falls back to the vanilla
-- call if no candidate qualifies, so behaviour is never worse than stock.
function GetSmartCollectContainer( shape, itemUid, amount )
	local outputShapes = sm.pipeGraph.getOutputContainers( shape )
	local candidates = {}
	for _, s in ipairs( outputShapes ) do
		candidates[#candidates + 1] = { shape = s }
	end

	local best = FindContainerToCollectTo( candidates, itemUid, amount )
	if best then
		return best.shape
	end

	return sm.pipeGraph.getContainerShapeToCollectTo( shape, { itemUid }, { amount } )
end

function FindContainerToSpendFrom( containers, itemUid, amount )
	for _, container in ipairs( containers ) do
		if sm.container.canSpend( container.shape:getInteractable():getContainer(), itemUid, amount ) then
			return container
		end
	end
end

PipeStateOverrideTable = {
	[PipeState.off] = {
		[PipeState.off] = false,
		[PipeState.invalid] = true,
		[PipeState.connected] = true,
		[PipeState.valid] = true,
	},
	[PipeState.invalid] = {
		[PipeState.off] = false,
		[PipeState.invalid] = false,
		[PipeState.connected] = false,
		[PipeState.valid] = false,
	},
	[PipeState.connected] = {
		[PipeState.off] = false,
		[PipeState.invalid] = true,
		[PipeState.connected] = false,
		[PipeState.valid] = true,
	},
	[PipeState.valid] = {
		[PipeState.off] = false,
		[PipeState.invalid] = true,
		[PipeState.connected] = false,
		[PipeState.valid] = false,
	},
}

function LightUpPipes( arrayPipes, fnOverride )
	for  _, pipe in ipairs( arrayPipes ) do
		local shape = pipe.shape
		local state = pipe.state
		if sm.exists( shape ) then
			local pipeGlow = 1.0

			if fnOverride then
				state, pipeGlow = fnOverride( pipe )
			end

			local currentUvFrameIndex = shape:getInteractable():getUvFrameIndex() + 1
			if PipeStateOverrideTable[currentUvFrameIndex][state] then
				shape:getInteractable():setUvFrameIndex( state - 1 )
				shape:getInteractable():setGlowMultiplier( pipeGlow )
			end
		end
	end
end

PipeEffectNode = class()

function PipeEffectNode.shapeExists( self )
	return self.shape:shapeExists()
end

function PipeEffectNode.getWorldPosition( self )
	return self.shape:transformLocalPoint( self.point )
end

PipeEffectPlayer = class()

local function ValidatePath( shapeList )

	local function checkConnection( index1, index2 )
		local offsets = shapeList[index1]:getPipeOffsets()
		if #offsets > 0 then
			local closestPoint = sm.vec3.new( 0, 0, 0 )
			local closestDistance = math.huge
			local toPoint = shapeList[index2]:getWorldPosition()
			for _, offset in ipairs( offsets ) do
				local fromPoint = shapeList[index1]:transformLocalPoint( offset )
				local distanceSqr = ( fromPoint - toPoint ):length2()
				if distanceSqr < closestDistance then
					closestDistance = distanceSqr
					closestPoint = offset
				end
			end
			local startNode = PipeEffectNode()
			startNode.shape = shapeList[index1]
			startNode.point = closestPoint * sm.construction.constants.subdivideRatio
			shapeList[index1] = startNode
		end
	end

	for index = 1, #shapeList do
		if type( shapeList[index] ) == "Shape" and not shapeList[index]:isPipe() then
			local index2 = index - 1
			if index == 1 then
				index2 = index + 1
			end
			checkConnection( index, index2 )
		end
	end

	return shapeList
end

function PipeEffectPlayer.onCreate( self )
	self.effectTasks = {}
end

function PipeEffectPlayer.onDestroy( self )
	for _, task in ipairs( self.effectTasks ) do
		if task.effect then
			task.effect:destroy()
		end
	end
	self.effectTasks = {}
end

function PipeEffectPlayer.pushShapeEffectTask( self, shapeList, item, delay, minimumDuration )

	shapeList = ValidatePath( shapeList )

	assert( item )
	local effect = sm.effect.createEffect( "ShapeRenderable" )
	if sm.item.isTool( item ) then
		item = GetToolProxyItem( item )
	end
	local bounds = sm.item.getShapeSize( item )
	assert( bounds )
	effect:setParameter( "uuid", item )
	effect:setPosition( shapeList[1]:getWorldPosition() )

	local scale = sm.construction.constants.subdivideRatio / ( ( bounds.x + bounds.y + bounds.z ) / 3.0 );
	effect:setScale( sm.vec3.new( scale, scale, scale ) )

	minimumDuration = minimumDuration or PIPE_MINIMUM_DURATION
	self:pushEffectTask( shapeList, effect, delay, minimumDuration )
end

function PipeEffectPlayer.pushEffectTask( self, shapeList, effect, delay, minimumDuration )
	table.insert( self.effectTasks, { shapeList = shapeList, effect = effect, progress = 0, delay = delay or 0, delayProgress = 0, minimumDuration = minimumDuration } )
end

function PipeEffectPlayer.update( self, dt )
	for idx, task in reverse_ipairs( self.effectTasks ) do

		if task.delayProgress >= task.delay then
			if task.progress == 0 then
				task.effect:start()
			end

			if task.progress > 0 and task.progress < 1 and #task.shapeList > 1 then
				local span = ( 1.0 / ( #task.shapeList - 1 ) )

				local b = math.ceil( task.progress / span ) + 1
				local a = b - 1
				local t = ( task.progress - ( a - 1 ) * span ) / span
				--print( "A: "..a.." B: "..b.." t: "..t)

				assert(a ~= 0 and a <= #task.shapeList)
				assert(b ~= 0 and b <= #task.shapeList)

				local nodeA = task.shapeList[a]
				local nodeB = task.shapeList[b]

				if pcall( function() nodeA:shapeExists() end ) and pcall( function() nodeB:shapeExists() end ) then
					local lerpedPosition = ( nodeA:getWorldPosition() * ( 1 - t ) ) + ( nodeB:getWorldPosition() * t )
					task.effect:setPosition( lerpedPosition )
				else
					task.progress = 1 -- End the effect
				end
			end

			task.progress = task.progress + dt / math.max( #task.shapeList * DURATION_PER_PIPE, task.minimumDuration )

			if task.progress >= 1 then
				task.effect:stop()
				table.remove( self.effectTasks, idx )
			end
		end
		task.delayProgress = task.delayProgress + dt
	end
end
