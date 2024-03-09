export class GroupChatroomParams {
    name: string;
    participantIds: string[];

    constructor(name: string, participantIds: string[]) {
        this.name = name;
        this.participantIds = participantIds;
    }
}