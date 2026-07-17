import { LightningElement, wire } from "lwc";
import getDashboardData from "@salesforce/apex/PlantsDashboardController.getDashboardData";
import { refreshApex } from "@salesforce/apex"; // ✅ AÑADIDO

const COLORS = ["#2f95e5", "#76b7eb", "#9447e9", "#bd8bef", "#5cb85c"];

export default class PlantsDashboard extends LightningElement {
    dashboard;
    error;
    loading = true;
    wiredResult;

    connectedCallback() {
        this.refreshData();
    }

    refreshData() {
        this.loading = true;
        if (this.wiredResult) {
            refreshApex(this.wiredResult)
                .then(() => {
                    this.loading = false;
                })
                .catch(() => {
                    this.loading = false;
                });
        }
    }

    @wire(getDashboardData)
    wiredDashboard(result) {
        this.wiredResult = result;
        this.dashboard = result.data;
        this.error = result.error;
        this.loading = false;
    }

    get speciesRows() {
        return this.prepareRows(this.dashboard?.plantsBySpecies);
    }

    get fertilizationRows() {
        return this.prepareRows(this.dashboard?.pendingFertilization);
    }

    get ownerRows() {
        return this.prepareRows(this.dashboard?.plantsByOwner);
    }

    get wateringRows() {
        return this.prepareRows(this.dashboard?.pendingWatering);
    }

    get totalPlants() {
        return this.speciesRows.reduce((total, row) => total + row.value, 0);
    }

    get speciesDonutStyle() {
        const rows = this.speciesRows;
        const total = this.totalPlants;

        if (!total) {
            return "background: #e5e7eb;";
        }

        let cursor = 0;
        const slices = rows.map((row, index) => {
            const start = cursor;
            const size = (row.value / total) * 100;
            cursor += size;
            return `${COLORS[index % COLORS.length]} ${start}% ${cursor}%`;
        });

        return `background: conic-gradient(${slices.join(", ")});`;
    }

    prepareRows(rows = []) {
        if (!rows || rows.length === 0) {
            return [];
        }
        const max = Math.max(...rows.map((row) => row.value), 1);

        return rows.map((row, index) => {
            const percent = Math.max((row.value / max) * 100, 4);
            const color = COLORS[index % COLORS.length];

            return {
                ...row,
                barStyle: `width: ${percent}%; background: ${color};`,
                columnStyle: `height: ${percent}%; background: ${color};`,
                dotStyle: `background: ${color};`
            };
        });
    }
}