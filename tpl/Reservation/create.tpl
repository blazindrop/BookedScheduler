{*
Copyright 2011-2015 Nick Korbel

This file is part of Booked Scheduler.

Booked Scheduler is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Booked Scheduler is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Booked Scheduler.  If not, see <http://www.gnu.org/licenses/>.
*}
{block name="header"}{include file='globalheader.tpl' Qtip=true}
{/block}

{function name="displayResource"}
	<div class="resourceName" style="background-color:{$resource->GetColor()};color:{$resource->GetTextColor()}">
		<span class="resourceDetails">{$resource->Name}</span>
		{if $resource->GetRequiresApproval()}<i class="fa fa-lock" data-tooltip="approval"></i>{/if}
		{if true || $resource->IsCheckInEnabled()}<i class="fa fa-check" data-tooltip="checkin"></i>{/if}
		{if true || $resource->IsAutoReleased()}<i class="fa fa-clock-o" data-tooltip="autorelease" data-autorelease="{$resource->GetAutoReleaseMinutes()}"></i>{/if}
	</div>
{/function}

<div id="page-reservation">
	<div id="reservation-box">
		<form id="form-reservation" method="post" enctype="multipart/form-data" role="form">

			<div class="row">
				<div class="col-m-6 col-xs-12 col-top reservationHeader">
					<h3>{block name=reservationHeader}{translate key="CreateReservationHeading"}{/block}</h3>
				</div>

				<div class="col-m-6 col-xs-12 col-top">
					<div class="pull-right">
						<button type="button" class="btn btn-default" onclick="window.location='{$ReturnUrl}'">
							{translate key='Cancel'}
						</button>
						{block name="submitButtons"}
							<button type="button" class="btn btn-success save create">
								<span class="glyphicon glyphicon-ok-circle"></span>
								{translate key='Create'}
							</button>
						{/block}
					</div>
				</div>
			</div>

			<div class="row">
				{assign var="detailsCol" value="col-xs-12"}
				{assign var="participantCol" value="col-xs-12"}

				{if $ShowParticipation && $AllowParticipation && $ShowReservationDetails}
					{assign var="detailsCol" value="col-xs-12 col-sm-6"}
					{assign var="participantCol" value="col-xs-12 col-sm-6"}
				{/if}

				<div id="reservationDetails" class="{$detailsCol}">

					<div class="col-xs-12">
						<div class="form-group">
							{if $ShowUserDetails && $ShowReservationDetails}
								<a href="#" id="userName" data-userid="{$UserId}">{$ReservationUserName}</a>
							{else}
								{translate key=Private}
							{/if}
							<input id="userId" type="hidden" {formname key=USER_ID} value="{$UserId}"/>
							{if $CanChangeUser}
								<a href="#" id="showChangeUsers" class="small-action">{translate key=Change} <i class="fa fa-user"></i></a>
								<div class="modal fade" id="changeUserDialog" tabindex="-1" role="dialog" aria-labelledby="usersModalLabel" aria-hidden="true">
									<div class="modal-dialog">
										<div class="modal-content">
											<div class="modal-header">
												<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
												<h4 class="modal-title" id="usersModalLabel">{translate key=ChangeUser}</h4>
											</div>
											<div class="modal-body">
											</div>
											<div class="modal-footer">
												<button type="button" class="btn btn-default" data-dismiss="modal">{translate key='Cancel'}</button>
												<button type="button" class="btn btn-primary">{translate key='Done'}</button>
											</div>
										</div>
									</div>
								</div>
							{/if}
						</div>
					</div>

					<div class="col-xs-12" id="changeUsers">
						<div class="form-group">
							<input type="text" id="changeUserAutocomplete" class="form-control inline-block user-search"/>
							|
							<button id="promptForChangeUsers" type="button" class="btn inline">
								<i class="fa fa-users"></i>
								{translate key='AllUsers'}
							</button>
						</div>
					</div>

					<div class="col-xs-12" id="reservation-resources">
						<div class="form-group">
							<div class="pull-left">
								<div>
									<label>{translate key="Resources"}</label>
									{if $ShowAdditionalResources}
										<a id="btnAddResources" href="#"
										   class="small-action" data-toggle="modal" data-target="#dialogResourceGroups">{translate key=Add} <span
													class="fa fa-plus-square"></span></a>
									{/if}
								</div>

								<div id="primaryResourceContainer" class="inline">
									<input type="hidden" id="scheduleId" {formname key=SCHEDULE_ID} value="{$ScheduleId}"/>
									<input class="resourceId" type="hidden" id="primaryResourceId" {formname key=RESOURCE_ID} value="{$ResourceId}"/>
									{displayResource resource=$Resource}
								</div>

								<div id="additionalResources">
									{foreach from=$AvailableResources item=resource}
										{if is_array($AdditionalResourceIds) && in_array($resource->Id, $AdditionalResourceIds)}
											<input class="resourceId" type="hidden" name="{FormKeys::ADDITIONAL_RESOURCES}[]" value="{$resource->Id}"/>
											{displayResource resource=$resource}
										{/if}
									{/foreach}
								</div>
							</div>
							<div class="pull-right">
								{if $ShowReservationDetails && $AvailableAccessories|count > 0}
									<label>{translate key="Accessories"}</label>
									<a href="#" id="addAccessoriesPrompt"
									   class="small-action" data-toggle="modal" data-target="#dialogAddAccessories">{translate key='Add'} <span
												class="fa fa-plus-square"></span></a>
									<div id="accessories"></div>
								{/if}
							</div>
						</div>
					</div>

					<div class="col-xs-12 reservationDates">
						<div class="col-md-6 no-padding-left">
							<div class="form-group no-margin-bottom">
								<label for="BeginDate" class="reservationDate">{translate key='BeginDate'}</label>
								<input type="text" id="BeginDate" class="form-control inline-block dateinput"
									   value="{formatdate date=$StartDate}"/>
								<input type="hidden" id="formattedBeginDate" {formname key=BEGIN_DATE}
									   value="{formatdate date=$StartDate key=system}"/>
								<select id="BeginPeriod" {formname key=BEGIN_PERIOD} class="form-control inline-block timeinput" title="Begin time">
									{foreach from=$StartPeriods item=period}
										{if $period->IsReservable()}
											{assign var='selected' value=''}
											{if $period eq $SelectedStart}
												{assign var='selected' value=' selected="selected"'}
											{/if}
											<option value="{$period->Begin()}"{$selected}>{$period->Label()}</option>
										{/if}
									{/foreach}
								</select>
							</div>
						</div>
						<div class="col-md-6 no-padding-left">
							<div class="form-group no-margin-bottom">
								<label for="EndDate" class="reservationDate">{translate key='EndDate'}</label>
								<input type="text" id="EndDate" class="form-control inline-block dateinput" value="{formatdate date=$EndDate}"/>
								<input type="hidden" id="formattedEndDate" {formname key=END_DATE}
									   value="{formatdate date=$EndDate key=system}"/>
								<select id="EndPeriod" {formname key=END_PERIOD} class="form-control inline-block timeinput" title="End time">
									{foreach from=$EndPeriods item=period name=endPeriods}
										{if $period->BeginDate()->IsMidnight()}
											<option value="{$period->Begin()}"{$selected}>{$period->Label()}</option>
										{/if}
										{if $period->IsReservable()}
											{assign var='selected' value=''}
											{if $period eq $SelectedEnd}
												{assign var='selected' value=' selected="selected"'}
											{/if}
											<option value="{$period->End()}"{$selected}>{$period->LabelEnd()}</option>
										{/if}
									{/foreach}
								</select>
							</div>
						</div>

					</div>
					<div class="col-md-12 reservationLength">
						<div class="form-group">
							<span class="like-label">{translate key=ReservationLength}</span>
							<div class="durationText">
								<span id="durationDays">0</span> {translate key=days},
								<span id="durationHours">0</span> {translate key=hours}
							</div>
						</div>
					</div>
					{if !$HideRecurrence}
						<div class="col-xs-12">
							{control type="RecurrenceControl" RepeatTerminationDate=$RepeatTerminationDate}
						</div>
					{/if}
					<div class="col-xs-12 reservationTitle">
						<div class="form-group has-feedback">
							<label for="reservationTitle">{translate key="ReservationTitle"}</label>
							{textbox name="RESERVATION_TITLE" class="form-control" value="ReservationTitle" id="reservationTitle"}
							{*<i class="glyphicon glyphicon-asterisk form-control-feedback" data-bv-icon-for="reservationTitle"></i>*}
						</div>
					</div>
					<div class="col-xs-12">
						<div class="form-group">
							<label for="description">{translate key="ReservationDescription"}</label>
							<textarea id="description" name="{FormKeys::DESCRIPTION}"
									  class="form-control">{$Description}</textarea>
						</div>
					</div>
				</div>

				<div class="{$participantCol}">
					{if $ShowParticipation && $AllowParticipation && $ShowReservationDetails}
						{include file="Reservation/participation.tpl"}
					{else}
						{include file="Reservation/private-participation.tpl"}
					{/if}
				</div>
			</div>

			<div class="row">
				<div id="custom-attributes-placeholder" class="col-xs-12">
				</div>
			</div>

			{if $RemindersEnabled}
				<div class="row">
					<div class="col-xs-12 reservationReminders">
						<div>
							<label for="startReminderEnabled">{translate key=SendReminder}</label>
						</div>
						<div id="reminderOptionsStart">
							<div class="checkbox">
								<input type="checkbox" id="startReminderEnabled" class="reminderEnabled" {formname key=START_REMINDER_ENABLED}/>
								<label for="startReminderEnabled">
									<input type="number" min="0" max="999" size="3" maxlength="3" value="15"
										   class="reminderTime form-control input-sm inline-block" {formname key=START_REMINDER_TIME}/>
									<select class="reminderInterval form-control input-sm inline-block" {formname key=START_REMINDER_INTERVAL}>
										<option value="{ReservationReminderInterval::Minutes}">{translate key=minutes}</option>
										<option value="{ReservationReminderInterval::Hours}">{translate key=hours}</option>
										<option value="{ReservationReminderInterval::Days}">{translate key=days}</option>
									</select>
									<span class="reminderLabel">{translate key=ReminderBeforeStart}</span></label>
							</div>
						</div>
						<div id="reminderOptionsEnd">
							<div class="checkbox">
								<input type="checkbox" id="endReminderEnabled" class="reminderEnabled" {formname key=END_REMINDER_ENABLED}/>
								<label for="endReminderEnabled">
									<input type="number" min="0" max="999" size="3" maxlength="3" value="15"
										   class="reminderTime form-control input-sm inline-block" {formname key=END_REMINDER_TIME}/>
									<select class="reminderInterval form-control input-sm inline-block" {formname key=END_REMINDER_INTERVAL}>
										<option value="{ReservationReminderInterval::Minutes}">{translate key=minutes}</option>
										<option value="{ReservationReminderInterval::Hours}">{translate key=hours}</option>
										<option value="{ReservationReminderInterval::Days}">{translate key=days}</option>
									</select>
									<span class="reminderLabel">{translate key=ReminderBeforeEnd}</span></label>
							</div>

						</div>
						<div class="clear">&nbsp;</div>
					</div>
				</div>
			{/if}

			{if $UploadsEnabled}
				<div class="row">
					<div class="col-xs-12 reservationAttachments">

						<label>{translate key=AttachFile} <span class="note">({$MaxUploadSize}
								MB {translate key=Maximum})</span><br/> </label>

						<div id="reservationAttachments">
							<div class="attachment-item">
								<input type="file" {formname key=RESERVATION_FILE multi=true} />
								<a class="add-attachment" href="#">{translate key=Add} <i class="fa fa-plus-square"></i></a>
								<a class="remove-attachment" href="#"><i class="fa fa-minus-square"></i></a>
							</div>
						</div>
					</div>
				</div>
			{/if}

			<input type="hidden" {formname key=RESERVATION_ID} value="{$ReservationId}"/>
			<input type="hidden" {formname key=REFERENCE_NUMBER} value="{$ReferenceNumber}" id="referenceNumber"/>
			<input type="hidden" {formname key=RESERVATION_ACTION} value="{$ReservationAction}"/>

			<input type="hidden" {formname key=SERIES_UPDATE_SCOPE} id="hdnSeriesUpdateScope"
				   value="{SeriesUpdateScope::FullSeries}"/>

			<div class="row">
				<div class="reservationButtons col-m-6 col-m-offset-6 col-xs-12">
					<div class="reservationSubmitButtons">
						<button type="button" class="btn btn-default" onclick="window.location='{$ReturnUrl}'">
							{translate key='Cancel'}
						</button>
						{block name="submitButtons"}
							<button type="button" class="btn btn-success save create">
								<span class="glyphicon glyphicon-ok-circle"></span>
								{translate key='Create'}
							</button>
						{/block}
					</div>
				</div>
			</div>

			{csrf_token}

			{if $UploadsEnabled}
				{block name='attachments'}
				{/block}
			{/if}

			<div id="retrySubmitParams" class="no-show"></div>
		</form>
	</div>

	<div class="modal fade" id="dialogResourceGroups" tabindex="-1" role="dialog" aria-labelledby="resourcesModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="resourcesModalLabel">{translate key=AddResources}</h4>
				</div>
				<div class="modal-body">
					<div id="resourceGroups"></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default btnClearAddResources" data-dismiss="modal">{translate key='Cancel'}</button>
					<button type="button" class="btn btn-primary btnConfirmAddResources">{translate key='Done'}</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="dialogAddAccessories" tabindex="-1" role="dialog" aria-labelledby="accessoryModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="accessoryModalLabel">{translate key=AddAccessories}</h4>
				</div>
				<div class="modal-body">
					<table class="table table-condensed">
						<thead>
						<tr>
							<th>{translate key=Accessory}</th>
							<th>{translate key=QuantityRequested}</th>
							<th>{translate key=QuantityAvailable}</th>
						</tr>
						</thead>
						<tbody>
						{foreach from=$AvailableAccessories item=accessory}
							<tr accessory-id="{$accessory->GetId()}">
								<td>{$accessory->GetName()}</td>
								<td>
									<input type="hidden" class="name" value="{$accessory->GetName()}"/>
									<input type="hidden" class="id" value="{$accessory->GetId()}"/>
									<input type="hidden" class="resource-ids" value="{','|implode:$accessory->ResourceIds()}"/>
									{if $accessory->GetQuantityAvailable() == 1}
										<input type="checkbox" name="accessory{$accessory->GetId()}" value="1" size="3"/>
									{else}
										<input type="number" min="0" max="999" class="form-control accessory-quantity" name="accessory{$accessory->GetId()}"
											   value="0" size="3"/>
									{/if}
								</td>
								<td>{$accessory->GetQuantityAvailable()|default:'&infin;'}</td>
							</tr>
						{/foreach}
						</tbody>
					</table>

				</div>
				<div class="modal-footer">
					<button id="btnCancelAddAccessories" type="button" class="btn btn-default"
							data-dismiss="modal">{translate key='Cancel'}</button>
					<button id="btnConfirmAddAccessories" type="button"
							class="btn btn-primary">{translate key='Done'}</button>
				</div>
			</div>
		</div>
	</div>

	<div id="wait-box" class="wait-box">
		<div id="creatingNotification">
			<h3>
				{block name="ajaxMessage"}
					{translate key=CreatingReservation}
				{/block}
			</h3>
			{html_image src="reservation_submitting.gif"}
		</div>
		<div id="result"></div>
	</div>

</div>

{control type="DatePickerSetupControl" ControlId="BeginDate" AltId="formattedBeginDate" DefaultDate=$StartDate}
{control type="DatePickerSetupControl" ControlId="EndDate" AltId="formattedEndDate" DefaultDate=$EndDate}
{control type="DatePickerSetupControl" ControlId="EndRepeat" AltId="formattedEndRepeat" DefaultDate=$RepeatTerminationDate}

{jsfile src="js/jquery.autogrow.js"}
{jsfile src="js/moment.min.js"}
{jsfile src="resourcePopup.js"}
{jsfile src="userPopup.js"}
{jsfile src="date-helper.js"}
{jsfile src="recurrence.js"}
{jsfile src="reservation.js"}
{jsfile src="autocomplete.js"}
{jsfile src="force-numeric.js"}
{jsfile src="reservation-reminder.js"}
{jsfile src="js/tree.jquery.js"}

<script type="text/javascript">

	$(function () {
		var scopeOptions = {
			instance: '{SeriesUpdateScope::ThisInstance}',
			full: '{SeriesUpdateScope::FullSeries}',
			future: '{SeriesUpdateScope::FutureInstances}'
		};

		var reservationOpts = {
			additionalResourceElementId: '{FormKeys::ADDITIONAL_RESOURCES}',
			accessoryListInputId: '{FormKeys::ACCESSORY_LIST}[]',
			returnUrl: '{$ReturnUrl}',
			scopeOpts: scopeOptions,
			createUrl: 'ajax/reservation_save.php',
			updateUrl: 'ajax/reservation_update.php',
			deleteUrl: 'ajax/reservation_delete.php',
			userAutocompleteUrl: "ajax/autocomplete.php?type={AutoCompleteType::User}",
			groupAutocompleteUrl: "ajax/autocomplete.php?type={AutoCompleteType::Group}",
			changeUserAutocompleteUrl: "ajax/autocomplete.php?type={AutoCompleteType::MyUsers}",
			maxConcurrentUploads: '{$MaxUploadCount}'
		};

		var recurOpts = {
			repeatType: '{$RepeatType}',
			repeatInterval: '{$RepeatInterval}',
			repeatMonthlyType: '{$RepeatMonthlyType}',
			repeatWeekdays: [{foreach from=$RepeatWeekdays item=day}{$day}, {/foreach}]
		};

		var reminderOpts = {
			reminderTimeStart: '{$ReminderTimeStart}',
			reminderTimeEnd: '{$ReminderTimeEnd}',
			reminderIntervalStart: '{$ReminderIntervalStart}',
			reminderIntervalEnd: '{$ReminderIntervalEnd}'
		};

		var recurrence = new Recurrence(recurOpts);
		recurrence.init();

		var reservation = new Reservation(reservationOpts);
		reservation.init('{$UserId}');

		var reminders = new Reminder(reminderOpts);
		reminders.init();

		{foreach from=$Participants item=user}
		reservation.addParticipant("{$user->FullName|escape:'javascript'}", "{$user->UserId|escape:'javascript'}");
		{/foreach}

		{foreach from=$Invitees item=user}
		reservation.addInvitee("{$user->FullName|escape:'javascript'}", '{$user->UserId}');
		{/foreach}

		{foreach from=$Accessories item=accessory}
		reservation.addAccessory('{$accessory->AccessoryId}', '{$accessory->QuantityReserved}', "{$accessory->Name|escape:'javascript'}");
		{/foreach}

		reservation.addResourceGroups({$ResourceGroupsAsJson});

		var ajaxOptions = {
			target: '#result', // target element(s) to be updated with server response
			beforeSubmit: reservation.preSubmit, // pre-submit callback
			success: reservation.showResponse  // post-submit callback
		};

		$('#form-reservation').submit(function () {
			$(this).ajaxSubmit(ajaxOptions);
			return false;
		});

		$('#description').autogrow();
		$('#userName').bindUserDetails();

		$.blockUI.defaults.css.width = '60%';
		$.blockUI.defaults.css.left = '20%';

		var resources = $('#reservation-resources');
		resources.tooltip({
		    selector: '[data-tooltip]',
			title: function(){
				var tooltipType = $(this).data('tooltip');
				if (tooltipType === 'approval')
				{
					return "Requires Approval";
				}
				if (tooltipType === 'checkin')
				{
					return "Requires Check In/Out";
				}
				if (tooltipType === 'autorelease')
				{
					return "Automatically released if not checked in within " + $(this).data('autorelease') + " minutes";
				}
			}
		});

	});
</script>

{include file='globalfooter.tpl'}
