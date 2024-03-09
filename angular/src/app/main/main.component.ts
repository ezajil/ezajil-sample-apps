import { Component, Input, OnInit } from '@angular/core';
import { Session, User } from 'ezajil-js-sdk';
import { environment } from '../../environments/environment.secret';

@Component({
  selector: 'app-main',
  templateUrl: './main.component.html',
  styleUrls: ['./main.component.scss']
})
export class MainComponent implements OnInit {
  @Input() currentUser!: User;
  session!: Session;
  isOnline!: boolean;
  reason!: string;
  code!: number;
  isClientError: boolean = false;
  requestOrigin: string;

  constructor() {
    this.requestOrigin = window.location.origin;
  }

  ngOnInit(): void {
    // These are environment variables necessary for the application to run.
    //
    // Instructions for configuring your environment:
    // 1. Copy or rename `environmet.template.ts` file to `environment.secret.ts`.
    // 2. Replace the placeholder values with your actual configuration settings (Create a project in https://dashboard.ezajil.io)
    //    - `endpoint`: This should be the URL to ezajil backend service.
    //    - `apiKey`: This is the key required to authenticate your access.
    // 3. Do no commit `environment.secret.ts` to your version control system (Git). 
    //    This file should be ignored by version control to protect your sensitive information.
    //    Ensure that `environment.secret.ts` is listed in your `.gitignore` file.
    // 4. The application will import values from `environment.secret.ts` for its configuration.
    //    Make sure the file is correctly named and located in the `src/environments/` directory.
    const endpoint = environment.endpoint;
    const apiKey = environment.apiKey;
    this.session = new Session(endpoint, apiKey, this.currentUser, {enableLogging: true});
    this.session
      .on('connected', () => {
        this.isOnline = true;
      })
      .on('disconnected', (code: number, reason: string, isClientError: boolean) => {
        this.isOnline = false;
        if (isClientError) {
          this.reason = reason;
          this.code = code;
          this.isClientError = isClientError;
        }
      })
      .on('error', (event: Event) => {
        console.error(`error: ${JSON.stringify(event)}`);
      });
      this.session.connect();
  }

}
