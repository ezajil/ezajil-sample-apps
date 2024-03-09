import { Component, HostListener, Input, OnChanges, OnInit, SimpleChanges, ViewChild } from '@angular/core';
import { Chatroom, Session, User } from 'ezajil-js-sdk';
import { GroupChatroomCreationModalComponent } from '../group-chatroom-creation-modal/group-chatroom-creation-modal.component';
import { GroupChatroomParams } from '../models/GroupChatroomParams';
import { SingleChatroomParams } from '../models/SingleChatroomParams';
import { SingleChatroomCreationModalComponent } from '../single-chatroom-creation-modal/single-chatroom-creation-modal.component';
import { ToastrService } from 'ngx-toastr';
import * as moment from 'moment';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss']
})
export class SidebarComponent implements OnInit, OnChanges {
  screenWidth: number = window.innerWidth;
  @Input() currentUser!: User;
  @Input() isOnline!: boolean;
  @Input() session!: Session;
  @ViewChild(SingleChatroomCreationModalComponent) singleChatroomCreationModal?: SingleChatroomCreationModalComponent;
  @ViewChild(GroupChatroomCreationModalComponent) groupChatroomCreationModal?: GroupChatroomCreationModalComponent;
  singleChatroomsPagingState: string | null = null;
  groupChatroomsPagingState: string | null = null;
  visibleChatroomIds: string[] = [];
  singleChatrooms: [User, Chatroom][] = [];
  groupChatrooms: Chatroom[] = [];

  get visibleChatrooms(): Chatroom[] {
    return this.singleChatrooms.map(([_, chatroom]) => chatroom).concat(this.groupChatrooms)
      .filter(chatroom => this.visibleChatroomIds.includes(chatroom.chatroomId));
  }

  constructor(private toastr: ToastrService) { }

  @HostListener('window:resize', ['$event'])
  onWindowResize(event: Event) {
    this.screenWidth = window.innerWidth;
  }

  ngOnInit(): void {
    this.setupSidebar();
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['isOnline']) {
      const currentValue = changes['isOnline'].currentValue;
      const previousValue = changes['isOnline'].previousValue;

      if (currentValue === false) {
        this.visibleChatroomIds = [];
        this.singleChatrooms = [];
        this.groupChatrooms = [];
      } else {
        this.setupSidebar();
      }
    }
  }

  private setupSidebar() {
    if (!this.isOnline) {
      return;
    }
    this.session
      .on('online-user', (onlineUser) => {
        this.singleChatrooms = this.singleChatrooms.map(([user, chatroom]) => {
          if (user.userId === onlineUser.userId) {
            return [{ ...user, online: true, lastSeen: onlineUser.lastSeen }, chatroom];
          }
          return [user, chatroom];
        });
      })
      .on('offline-user', (offlineUser) => {
        this.singleChatrooms = this.singleChatrooms.map(([user, chatroom]) => {
          if (user.userId === offlineUser.userId) {
            return [{ ...user, online: false, lastSeen: offlineUser.lastSeen }, chatroom];
          }
          return [user, chatroom];
        });
      })
      .on('chat-message', (chatMessage) => {
        const chatroomId = chatMessage.chatroomId;
        const isChatroomExist = this.groupChatrooms.some(groupChatroom => groupChatroom.chatroomId === chatroomId) ||
          this.singleChatrooms.some(([_, chatroom]) => chatroom.chatroomId === chatroomId);

        if (!isChatroomExist) {
          this.session.getChatroom(chatroomId, (chatroom, error) => {
            if (error) {
              this.toastr.error(error.message, 'error');
              return;
            }
            if (chatroom!.single) {
              this.addSingleChatroom(chatroom!);
            } else {
              this.addGroupChatroom(chatroom!);
            }
          });
        }
        // TODO: display notification
        this.session.markMessageAsDelivered(chatroomId, chatMessage.sendingDate);
      });

    this.singleChatroomsPagingState = null;
    this.groupChatroomsPagingState = null;
    this.fetchSingleChatrooms();
    this.fetchGroupChatrooms();
  }

  private fetchSingleChatrooms() {
    this.session.getSingleChatroomsOfUser((singleChatrooms, pagingState, _, error) => {
      if (!!error) {
        this.toastr.error(error.message, 'error');
        return;
      }
      this.singleChatroomsPagingState = pagingState;
      singleChatrooms?.forEach(singleChatroom => this.addSingleChatroom(singleChatroom));
    }, this.singleChatroomsPagingState, 10);
  }

  private fetchGroupChatrooms() {
    this.session.getGroupChatroomsOfUser((groupChatrooms, pagingState, _, error) => {
      if (!!error) {
        this.toastr.error(error.message, 'error');
        return;
      }
      this.groupChatroomsPagingState = pagingState;
      groupChatrooms?.forEach(groupChatroom => this.addGroupChatroom(groupChatroom));
    }, this.groupChatroomsPagingState, 10);
  }

  onSingleChatroomsScroll(event: Event) {
    const scrollContainer = event.target as HTMLElement;
    const atBottom = scrollContainer.scrollTop + scrollContainer.clientHeight === scrollContainer.scrollHeight;
    if (atBottom) {
      this.fetchSingleChatrooms();
    }
  }

  onGroupChatroomsScroll(event: Event) {
    const scrollContainer = event.target as HTMLElement;
    const atBottom = scrollContainer.scrollTop + scrollContainer.clientHeight === scrollContainer.scrollHeight;
    if (atBottom) {
      this.fetchGroupChatrooms();
    }
  }

  openSingleChatroomCreationModal() {
    this.singleChatroomCreationModal?.openModal();
  }

  onSingleChatroomCreation(singleChatroomParams: SingleChatroomParams) {
    this.session.createSingleChatroom(singleChatroomParams.name, singleChatroomParams.participantId, new Map(), (chatroom, error) => {
      if (error) {
        this.toastr.error(error.message, 'error');
        return;
      }
      this.addSingleChatroom(chatroom!);
    });
  }

  addSingleChatroom(chatroom: Chatroom) {
    const alreadyExists = this.singleChatrooms.some(existingChatroom => existingChatroom[1].chatroomId === chatroom.chatroomId);
    if (!alreadyExists) {
      const otherUserId = this.resolveOtherUserIdInSingleChatroom(chatroom);
      this.session.subscribeToUsersPresence([otherUserId], (users, error) => {
        if (!!error) {
          this.toastr.error(error.message);
          return;
        }
        this.singleChatrooms.push([users![0], chatroom]);
      });
    }
  }

  private resolveOtherUserIdInSingleChatroom(singleChatroom: Chatroom): string {
    if (singleChatroom.participantIds.length === 1) {
      return singleChatroom.participantIds[0];
    }
    return this.currentUser.userId === singleChatroom.participantIds[0] ?
      singleChatroom.participantIds[1] : singleChatroom.participantIds[0];
  }

  openGroupChatroomCreationModal() {
    this.groupChatroomCreationModal?.openModal();
  }

  onGroupChatroomCreation(groupChatroomParams: GroupChatroomParams) {
    this.session.createGroupChatroom(groupChatroomParams.name, groupChatroomParams.participantIds, new Map(),
      (chatroom, error) => {
        if (error) {
          this.toastr.error(error.message);
          return;
        }
        this.addGroupChatroom(chatroom!);
      });
  }

  addGroupChatroom(chatroom: Chatroom) {
    let alreadyExists = this.groupChatrooms.some(existingChatroom => existingChatroom.chatroomId === chatroom.chatroomId);
    if (!alreadyExists) {
      this.groupChatrooms.push(chatroom);
    }
  }

  onChatroomClick(chatroom: Chatroom) {
    if (this.visibleChatroomIds.includes(chatroom.chatroomId)) {
      this.visibleChatroomIds = this.visibleChatroomIds.filter(id => id !== chatroom.chatroomId);
    } else {
      this.visibleChatroomIds.push(chatroom.chatroomId);

      // If there are more chatrooms than visible slots, remove the oldest one
      const maxVisibleChatrooms = this.getMaxVisibleChatrooms();
      if (this.visibleChatroomIds.length > maxVisibleChatrooms) {
        this.visibleChatroomIds.shift();
      }
    }
  }

  private getMaxVisibleChatrooms(): number {
    const chatboxWidth = 380;   // Adjust the width of each chatbox as needed
    return Math.floor((this.screenWidth - 332 /* sidebar width */) / chatboxWidth);
  }

  formatLastSeen(nanoTimestamp: number): string | null {
    if (!nanoTimestamp) {
      return null;
    }
    const milliseconds = Math.floor(nanoTimestamp / 1e6);
    const lastSeenDate = new Date(milliseconds);
    const duration: string = moment(lastSeenDate).fromNow();
    return `Last seen ${duration}`;
  }
}
