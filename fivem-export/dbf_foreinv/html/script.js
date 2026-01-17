/* ═══════════════════════════════════════════════════════════════════
   DBF_FOREINV - ForeState Inventory Script
   ═══════════════════════════════════════════════════════════════════ */

const Inventory = {
    container: null,
    config: {},
    slots: [],
    equipment: {},
    selectedSlot: null,
    draggedItem: null,
    draggedSlotId: null,
    
    // ═══════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════
    
    init() {
        this.container = document.getElementById('inventory-container');
        this.contextMenu = document.getElementById('context-menu');
        this.tooltip = document.getElementById('item-tooltip');
        this.itemGrid = document.getElementById('item-grid');
        
        this.setupEventListeners();
        this.setupNUIListeners();
        
        console.log('[dbf_foreinv] Inventory UI initialized');
    },
    
    setupEventListeners() {
        // Close button
        document.getElementById('close-btn').addEventListener('click', () => {
            this.close();
        });
        
        // Search
        document.getElementById('search-input').addEventListener('input', (e) => {
            this.filterItems(e.target.value);
        });
        
        // Category filters
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                this.filterByCategory(btn.dataset.category);
            });
        });
        
        // Close context menu on click outside
        document.addEventListener('click', (e) => {
            if (!e.target.closest('.context-menu') && !e.target.closest('.item-slot')) {
                this.hideContextMenu();
            }
        });
        
        // Context menu actions
        this.contextMenu.querySelectorAll('.context-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const action = btn.dataset.action;
                this.handleContextAction(action);
            });
        });
        
        // Dialog buttons
        document.querySelectorAll('.btn-cancel').forEach(btn => {
            btn.addEventListener('click', () => {
                this.hideAllDialogs();
            });
        });
        
        // Give dialog confirm
        document.querySelector('#give-dialog .btn-confirm').addEventListener('click', () => {
            this.confirmGive();
        });
        
        // Split dialog
        const splitSlider = document.getElementById('split-slider');
        const splitAmount = document.getElementById('split-amount');
        
        splitSlider.addEventListener('input', () => {
            splitAmount.value = splitSlider.value;
        });
        
        splitAmount.addEventListener('input', () => {
            splitSlider.value = splitAmount.value;
        });
        
        document.querySelector('#split-dialog .btn-confirm').addEventListener('click', () => {
            this.confirmSplit();
        });
        
        // ESC key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                if (!this.contextMenu.classList.contains('hidden')) {
                    this.hideContextMenu();
                } else if (!document.querySelector('.dialog:not(.hidden)')) {
                    this.close();
                } else {
                    this.hideAllDialogs();
                }
            }
        });
    },
    
    setupNUIListeners() {
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            switch (data.action) {
                case 'open':
                    this.open(data.config);
                    break;
                case 'close':
                    this.hide();
                    break;
                case 'updateInventory':
                    this.updateInventory(data.inventory, data.equipment, data.currentWeight, data.maxWeight);
                    break;
                case 'notify':
                    this.showNotification(data.message, data.type);
                    break;
            }
        });
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // OPEN / CLOSE
    // ═══════════════════════════════════════════════════════════════════
    
    open(config) {
        this.config = config || {};
        this.container.classList.remove('hidden');
        
        // Get player info
        this.fetchNUI('getPlayerName', {}).then(data => {
            if (data) {
                document.getElementById('player-name').textContent = data.name;
                document.getElementById('player-id').textContent = 'ID: ' + data.id;
            }
        });
        
        // Generate empty slots if needed
        if (this.itemGrid.children.length === 0) {
            this.generateSlots(config.maxSlots || 40);
        }
    },
    
    close() {
        this.fetchNUI('close', {});
    },
    
    hide() {
        this.container.classList.add('hidden');
        this.hideContextMenu();
        this.hideTooltip();
        this.hideAllDialogs();
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // SLOT GENERATION
    // ═══════════════════════════════════════════════════════════════════
    
    generateSlots(count) {
        this.itemGrid.innerHTML = '';
        
        for (let i = 0; i < count; i++) {
            const slot = document.createElement('div');
            slot.className = 'item-slot empty';
            slot.dataset.slotId = i;
            
            slot.innerHTML = '<div class="empty-indicator"></div>';
            
            // Event listeners
            slot.addEventListener('click', (e) => this.onSlotClick(e, i));
            slot.addEventListener('contextmenu', (e) => this.onSlotRightClick(e, i));
            slot.addEventListener('mouseenter', (e) => this.onSlotHover(e, i));
            slot.addEventListener('mouseleave', () => this.hideTooltip());
            
            // Drag and drop
            slot.draggable = true;
            slot.addEventListener('dragstart', (e) => this.onDragStart(e, i));
            slot.addEventListener('dragend', (e) => this.onDragEnd(e));
            slot.addEventListener('dragover', (e) => this.onDragOver(e, i));
            slot.addEventListener('dragleave', (e) => this.onDragLeave(e));
            slot.addEventListener('drop', (e) => this.onDrop(e, i));
            
            this.itemGrid.appendChild(slot);
        }
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // INVENTORY UPDATE
    // ═══════════════════════════════════════════════════════════════════
    
    updateInventory(inventory, equipment, currentWeight, maxWeight) {
        this.slots = inventory;
        this.equipment = equipment;
        
        // Update weight
        const weightPercent = (currentWeight / maxWeight) * 100;
        const weightFill = document.getElementById('weight-fill');
        const weightText = document.getElementById('weight-text');
        
        weightFill.style.width = Math.min(weightPercent, 100) + '%';
        weightFill.classList.toggle('warning', weightPercent > 80);
        weightText.textContent = currentWeight.toFixed(1) + ' / ' + maxWeight + ' kg';
        
        // Update slots
        for (const [slotId, slotData] of Object.entries(inventory)) {
            const slotElement = this.itemGrid.querySelector(`[data-slot-id="${slotId}"]`);
            if (!slotElement) continue;
            
            if (slotData.item) {
                this.renderItem(slotElement, slotData.item);
            } else {
                this.clearSlot(slotElement);
            }
        }
        
        // Update quickbar
        for (let i = 0; i < 6; i++) {
            const quickSlot = document.querySelector(`.quickbar-slot[data-slot="${i + 1}"]`);
            const invSlot = inventory[i];
            
            if (invSlot && invSlot.item) {
                quickSlot.innerHTML = `
                    <span class="slot-number">${i + 1}</span>
                    <span class="item-icon">${this.getItemEmoji(invSlot.item)}</span>
                `;
            } else {
                quickSlot.innerHTML = `<span class="slot-number">${i + 1}</span>`;
            }
        }
    },
    
    renderItem(slotElement, item) {
        slotElement.className = `item-slot rarity-${item.rarity}`;
        slotElement.innerHTML = `
            <span class="item-icon">${this.getItemEmoji(item)}</span>
            ${item.quantity > 1 ? `<span class="item-quantity">${item.quantity > 999 ? '999+' : item.quantity}</span>` : ''}
            ${item.durability !== undefined ? `
                <div class="item-durability">
                    <div class="item-durability-fill ${item.durability > 50 ? 'high' : item.durability > 25 ? 'medium' : 'low'}" 
                         style="width: ${item.durability}%"></div>
                </div>
            ` : ''}
        `;
        slotElement.dataset.item = JSON.stringify(item);
    },
    
    clearSlot(slotElement) {
        slotElement.className = 'item-slot empty';
        slotElement.innerHTML = '<div class="empty-indicator"></div>';
        delete slotElement.dataset.item;
    },
    
    getItemEmoji(item) {
        // Map categories to emojis (fallback)
        const categoryEmojis = {
            weapon: '🔫',
            ammo: '📦',
            food: '🍔',
            drink: '💧',
            medical: '🏥',
            clothing: '👕',
            tool: '🔧',
            material: '🔩',
            key: '🔑',
            money: '💵',
            drug: '💊',
            misc: '📦'
        };
        
        // Try to use icon from item data, or fallback to category emoji
        return item.icon ? `<img src="assets/${item.icon}" alt="${item.label}" class="item-img">` 
                        : categoryEmojis[item.category] || '📦';
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // SLOT EVENTS
    // ═══════════════════════════════════════════════════════════════════
    
    onSlotClick(e, slotId) {
        this.hideContextMenu();
        this.selectedSlot = slotId;
    },
    
    onSlotRightClick(e, slotId) {
        e.preventDefault();
        
        const slot = this.slots[slotId];
        if (!slot || !slot.item) return;
        
        this.selectedSlot = slotId;
        this.showContextMenu(e.clientX, e.clientY, slot.item);
    },
    
    onSlotHover(e, slotId) {
        const slot = this.slots[slotId];
        if (!slot || !slot.item) return;
        
        this.showTooltip(e.clientX, e.clientY, slot.item);
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // DRAG AND DROP
    // ═══════════════════════════════════════════════════════════════════
    
    onDragStart(e, slotId) {
        const slot = this.slots[slotId];
        if (!slot || !slot.item) {
            e.preventDefault();
            return;
        }
        
        this.draggedItem = slot.item;
        this.draggedSlotId = slotId;
        e.target.classList.add('dragging');
        
        // Set drag image
        e.dataTransfer.setData('text/plain', slotId.toString());
        e.dataTransfer.effectAllowed = 'move';
    },
    
    onDragEnd(e) {
        e.target.classList.remove('dragging');
        this.draggedItem = null;
        this.draggedSlotId = null;
        
        // Remove all drag-over classes
        this.itemGrid.querySelectorAll('.drag-over').forEach(el => {
            el.classList.remove('drag-over');
        });
    },
    
    onDragOver(e, slotId) {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        
        if (this.draggedSlotId !== slotId) {
            e.target.closest('.item-slot').classList.add('drag-over');
        }
    },
    
    onDragLeave(e) {
        e.target.closest('.item-slot')?.classList.remove('drag-over');
    },
    
    onDrop(e, slotId) {
        e.preventDefault();
        e.target.closest('.item-slot')?.classList.remove('drag-over');
        
        if (this.draggedSlotId === null || this.draggedSlotId === slotId) return;
        
        this.fetchNUI('moveItem', {
            fromSlot: this.draggedSlotId,
            toSlot: slotId,
            fromType: 'inventory',
            toType: 'inventory'
        });
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // CONTEXT MENU
    // ═══════════════════════════════════════════════════════════════════
    
    showContextMenu(x, y, item) {
        this.contextMenu.classList.remove('hidden');
        
        // Update header
        document.getElementById('context-item-icon').textContent = this.getItemEmoji(item);
        document.getElementById('context-item-name').textContent = item.label;
        document.getElementById('context-item-details').textContent = 
            `${item.quantity}x • ${(item.weight * item.quantity).toFixed(1)} kg`;
        
        // Show/hide use button based on usable
        const useBtn = this.contextMenu.querySelector('.use-btn');
        useBtn.style.display = item.usable ? 'flex' : 'none';
        
        // Show/hide split button based on quantity
        const splitBtn = this.contextMenu.querySelector('.split-btn');
        splitBtn.style.display = item.quantity > 1 ? 'flex' : 'none';
        
        // Position menu
        const menuRect = this.contextMenu.getBoundingClientRect();
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;
        
        let posX = x;
        let posY = y;
        
        if (x + menuRect.width > viewportWidth) {
            posX = x - menuRect.width;
        }
        if (y + menuRect.height > viewportHeight) {
            posY = y - menuRect.height;
        }
        
        this.contextMenu.style.left = posX + 'px';
        this.contextMenu.style.top = posY + 'px';
    },
    
    hideContextMenu() {
        this.contextMenu.classList.add('hidden');
    },
    
    handleContextAction(action) {
        const slot = this.slots[this.selectedSlot];
        if (!slot || !slot.item) return;
        
        const item = slot.item;
        
        switch (action) {
            case 'use':
                this.fetchNUI('useItem', { item: item.name, slot: this.selectedSlot });
                break;
            case 'examine':
                this.showNotification(`${item.label}: ${item.description}`, 'info');
                break;
            case 'split':
                this.showSplitDialog(item);
                break;
            case 'give':
                this.showGiveDialog(item);
                break;
            case 'drop':
                this.fetchNUI('dropItem', { item: item.name, slot: this.selectedSlot, amount: item.quantity });
                break;
            case 'destroy':
                if (confirm(`Wirklich ${item.label} zerstören?`)) {
                    this.fetchNUI('destroyItem', { item: item.name, slot: this.selectedSlot });
                }
                break;
        }
        
        this.hideContextMenu();
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // TOOLTIP
    // ═══════════════════════════════════════════════════════════════════
    
    showTooltip(x, y, item) {
        this.tooltip.classList.remove('hidden');
        
        document.getElementById('tooltip-icon').textContent = this.getItemEmoji(item);
        document.getElementById('tooltip-name').textContent = item.label;
        document.getElementById('tooltip-rarity').textContent = item.rarity.toUpperCase();
        document.getElementById('tooltip-rarity').className = `tooltip-rarity ${item.rarity}`;
        document.getElementById('tooltip-description').textContent = item.description;
        document.getElementById('tooltip-weight').textContent = `${(item.weight * item.quantity).toFixed(2)} kg`;
        document.getElementById('tooltip-quantity').textContent = item.quantity;
        
        const durabilityFill = document.getElementById('tooltip-durability');
        if (item.durability !== undefined) {
            durabilityFill.style.width = item.durability + '%';
            durabilityFill.className = `durability-fill ${item.durability > 50 ? 'high' : item.durability > 25 ? 'medium' : 'low'}`;
            durabilityFill.parentElement.parentElement.style.display = 'flex';
        } else {
            durabilityFill.parentElement.parentElement.style.display = 'none';
        }
        
        // Position tooltip
        const tooltipRect = this.tooltip.getBoundingClientRect();
        let posX = x + 15;
        let posY = y + 15;
        
        if (posX + tooltipRect.width > window.innerWidth) {
            posX = x - tooltipRect.width - 15;
        }
        if (posY + tooltipRect.height > window.innerHeight) {
            posY = y - tooltipRect.height - 15;
        }
        
        this.tooltip.style.left = posX + 'px';
        this.tooltip.style.top = posY + 'px';
    },
    
    hideTooltip() {
        this.tooltip.classList.add('hidden');
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // DIALOGS
    // ═══════════════════════════════════════════════════════════════════
    
    showGiveDialog(item) {
        const dialog = document.getElementById('give-dialog');
        dialog.classList.remove('hidden');
        
        document.getElementById('give-amount').max = item.quantity;
        document.getElementById('give-amount').value = 1;
        
        // Fetch nearby players
        this.fetchNUI('getNearbyPlayers', {}).then(players => {
            const select = document.getElementById('give-player');
            select.innerHTML = '';
            
            if (players && players.length > 0) {
                players.forEach(player => {
                    const option = document.createElement('option');
                    option.value = player.id;
                    option.textContent = `${player.name} (${player.distance.toFixed(1)}m)`;
                    select.appendChild(option);
                });
            } else {
                const option = document.createElement('option');
                option.value = '';
                option.textContent = 'Keine Spieler in der Nähe';
                select.appendChild(option);
            }
        });
    },
    
    showSplitDialog(item) {
        const dialog = document.getElementById('split-dialog');
        dialog.classList.remove('hidden');
        
        const maxSplit = item.quantity - 1;
        document.getElementById('split-amount').max = maxSplit;
        document.getElementById('split-amount').value = Math.floor(item.quantity / 2);
        document.getElementById('split-slider').max = maxSplit;
        document.getElementById('split-slider').value = Math.floor(item.quantity / 2);
    },
    
    hideAllDialogs() {
        document.querySelectorAll('.dialog').forEach(d => d.classList.add('hidden'));
    },
    
    confirmGive() {
        const slot = this.slots[this.selectedSlot];
        if (!slot || !slot.item) return;
        
        const amount = parseInt(document.getElementById('give-amount').value);
        const targetId = parseInt(document.getElementById('give-player').value);
        
        if (!targetId) {
            this.showNotification('Kein Spieler ausgewählt', 'error');
            return;
        }
        
        this.fetchNUI('giveItem', {
            item: slot.item.name,
            slot: this.selectedSlot,
            amount: amount,
            targetId: targetId
        });
        
        this.hideAllDialogs();
    },
    
    confirmSplit() {
        const slot = this.slots[this.selectedSlot];
        if (!slot || !slot.item) return;
        
        const amount = parseInt(document.getElementById('split-amount').value);
        
        this.fetchNUI('splitItem', {
            item: slot.item.name,
            slot: this.selectedSlot,
            amount: amount
        });
        
        this.hideAllDialogs();
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // FILTERING
    // ═══════════════════════════════════════════════════════════════════
    
    filterItems(query) {
        query = query.toLowerCase();
        
        this.itemGrid.querySelectorAll('.item-slot').forEach((slot, i) => {
            const slotData = this.slots[i];
            if (!slotData || !slotData.item) {
                slot.style.opacity = query ? '0.3' : '1';
                return;
            }
            
            const matches = slotData.item.label.toLowerCase().includes(query) ||
                          slotData.item.name.toLowerCase().includes(query);
            
            slot.style.opacity = matches || !query ? '1' : '0.3';
            slot.style.filter = matches || !query ? 'none' : 'grayscale(1)';
        });
    },
    
    filterByCategory(category) {
        this.itemGrid.querySelectorAll('.item-slot').forEach((slot, i) => {
            const slotData = this.slots[i];
            if (!slotData || !slotData.item) {
                slot.style.opacity = '1';
                slot.style.filter = 'none';
                return;
            }
            
            const matches = category === 'all' || slotData.item.category === category;
            
            slot.style.opacity = matches ? '1' : '0.3';
            slot.style.filter = matches ? 'none' : 'grayscale(1)';
        });
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════════════
    
    showNotification(message, type) {
        // Simple notification - can be replaced with a nicer one
        console.log(`[${type}] ${message}`);
    },
    
    // ═══════════════════════════════════════════════════════════════════
    // NUI COMMUNICATION
    // ═══════════════════════════════════════════════════════════════════
    
    async fetchNUI(eventName, data) {
        try {
            const response = await fetch(`https://dbf_foreinv/${eventName}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            return await response.json();
        } catch (e) {
            console.error('[dbf_foreinv] NUI fetch error:', e);
            return null;
        }
    }
};

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    Inventory.init();
});
