import { useState } from 'react';
import { InventorySystem } from '@/components/inventory';
import forestateLogo from '@/assets/forestate-logo.png';

const Index = () => {
  const [isInventoryOpen, setIsInventoryOpen] = useState(true);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      {/* Background Logo */}
      <div className="fixed inset-0 flex items-center justify-center opacity-5 pointer-events-none">
        <img src={forestateLogo} alt="" className="w-96 h-96 object-contain" />
      </div>

      {/* Demo Button when closed */}
      {!isInventoryOpen && (
        <div className="text-center z-10">
          <img src={forestateLogo} alt="ForeState" className="w-24 h-24 mx-auto mb-6 animate-float" />
          <h1 className="font-display text-4xl font-bold text-foreground text-glow mb-2">
            FORESTATE
          </h1>
          <p className="text-muted-foreground font-gaming mb-8">
            Midcore Roleplay Inventar System
          </p>
          <button
            onClick={() => setIsInventoryOpen(true)}
            className="px-8 py-3 bg-primary hover:bg-primary/80 text-primary-foreground font-display font-bold rounded-lg transition-all hover:scale-105 hover:shadow-[0_0_30px_rgba(162,0,255,0.4)]"
          >
            INVENTAR ÖFFNEN [TAB]
          </button>
        </div>
      )}

      {/* Inventory System */}
      <InventorySystem 
        isOpen={isInventoryOpen} 
        onClose={() => setIsInventoryOpen(false)} 
      />
    </div>
  );
};

export default Index;
