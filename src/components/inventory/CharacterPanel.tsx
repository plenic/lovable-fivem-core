import { motion } from 'framer-motion';
import { EquipmentSlot } from './EquipmentSlot';
import { EquipmentSlotData } from '@/types/inventory';
import forestateLogo from '@/assets/forestate-logo.png';

interface CharacterPanelProps {
  equipment: EquipmentSlotData[];
  playerName: string;
  playerId: string;
  onEquipmentClick?: (slot: EquipmentSlotData) => void;
  selectedSlot?: string;
}

export const CharacterPanel = ({
  equipment,
  playerName,
  playerId,
  onEquipmentClick,
  selectedSlot,
}: CharacterPanelProps) => {
  // Group equipment by position
  const leftSlots = equipment.filter(e => 
    ['bag', 'weapon_primary', 'weapon_secondary'].includes(e.slot)
  );
  const rightSlots = equipment.filter(e => 
    ['phone', 'keys', 'wallet'].includes(e.slot)
  );
  const centerSlots = equipment.filter(e => 
    ['head', 'face', 'torso', 'vest', 'legs', 'feet'].includes(e.slot)
  );

  return (
    <motion.div
      className="glass-panel glow-border rounded-2xl p-5 h-full flex flex-col"
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.3 }}
    >
      {/* Header with Logo */}
      <div className="flex items-center gap-3 mb-4">
        <img 
          src={forestateLogo} 
          alt="ForeState" 
          className="w-10 h-10 object-contain"
        />
        <div>
          <h2 className="font-display font-bold text-lg text-foreground text-glow">
            {playerName}
          </h2>
          <p className="text-xs text-muted-foreground font-gaming">
            ID: {playerId}
          </p>
        </div>
      </div>

      <div className="frost-line mb-4" />

      {/* Equipment Layout */}
      <div className="flex-1 flex items-center justify-center">
        <div className="flex gap-4">
          {/* Left Equipment (Weapons & Bag) */}
          <div className="flex flex-col gap-8 justify-center">
            {leftSlots.map((slot) => (
              <EquipmentSlot
                key={slot.slot}
                data={slot}
                onClick={() => onEquipmentClick?.(slot)}
                isSelected={selectedSlot === slot.slot}
              />
            ))}
          </div>

          {/* Center Equipment (Body) */}
          <div className="flex flex-col gap-8">
            {centerSlots.map((slot) => (
              <EquipmentSlot
                key={slot.slot}
                data={slot}
                onClick={() => onEquipmentClick?.(slot)}
                isSelected={selectedSlot === slot.slot}
              />
            ))}
          </div>

          {/* Right Equipment (Accessories) */}
          <div className="flex flex-col gap-8 justify-center">
            {rightSlots.map((slot) => (
              <EquipmentSlot
                key={slot.slot}
                data={slot}
                onClick={() => onEquipmentClick?.(slot)}
                isSelected={selectedSlot === slot.slot}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Player Stats */}
      <div className="frost-line my-4" />
      <div className="grid grid-cols-3 gap-2 text-center">
        <div className="bg-muted/30 rounded-lg py-2 px-3">
          <div className="text-lg font-display font-bold text-success">100%</div>
          <div className="text-[10px] text-muted-foreground uppercase">Gesundheit</div>
        </div>
        <div className="bg-muted/30 rounded-lg py-2 px-3">
          <div className="text-lg font-display font-bold text-primary">85%</div>
          <div className="text-[10px] text-muted-foreground uppercase">Rüstung</div>
        </div>
        <div className="bg-muted/30 rounded-lg py-2 px-3">
          <div className="text-lg font-display font-bold text-warning">72%</div>
          <div className="text-[10px] text-muted-foreground uppercase">Hunger</div>
        </div>
      </div>
    </motion.div>
  );
};
