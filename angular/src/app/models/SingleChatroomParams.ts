export class SingleChatroomParams {
    name: string;
    participantId: string;

    constructor(name: string, participantId: string) {
        this.name = name;
        this.participantId = participantId;
    }
}